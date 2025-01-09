Binoculars = {
  inAction = false,

  camera = nil,
  camCoords = vector3(0.0, 0.0, 0.0),
  camRotation = vector3(0.0, 0.0, 0.0),
  zoom = 5.0,
  mode = 1,
  scaleform = nil,
  camscaleform = nil,
  useModes = nil,
  stateTimer = nil,

  cache = {
    keybinds = {},
    commands = {}
  }
}

function Binoculars:InitMain()
  self:Debug("info", "Initializing main thread")

  self:InitKeybinds()
  self:InitCommands()

  self:Debug("info", "Main thread initialized")
end

local function DisableHudAndControls()
  HideHudAndRadarThisFrame()
  HideHudComponentThisFrame(19) -- weapon wheel
  HideHudComponentThisFrame(1)  -- Wanted Stars
  HideHudComponentThisFrame(2)  -- Weapon icon
  HideHudComponentThisFrame(3)  -- Cash
  HideHudComponentThisFrame(4)  -- MP CASH
  HideHudComponentThisFrame(13) -- Cash Change
  HideHudComponentThisFrame(11) -- Floating Help Text
  HideHudComponentThisFrame(12) -- more floating help text
  HideHudComponentThisFrame(15) -- Subtitle Text
  HideHudComponentThisFrame(18) -- Game Stream

  DisableAllControlActions(2)
end

function Binoculars:ToggleBinoculars(toggle, useModes)
  self.inAction = toggle or not self.inAction
  self:Debug("info", "Binoculars toggled: " .. (self.inAction and "on" or "off"))

  if self.inAction then
    self:ActivateBinoculars(useModes)
  else
    self:DeactivateBinoculars()
  end
end

function Binoculars:ActivateBinoculars(useModes)
  self:Debug("info", "Activating binoculars")
  self.useModes = useModes

  local playerPed = PlayerPedId()
  self.camRotation = -GetGameplayCamRot(2)

  self.camCoords = GetOffsetFromEntityInWorldCoords(playerPed, Config.CameraOffset.x, Config.CameraOffset.y,
    Config.CameraOffset.z)

  self.zoom = Config.Modes[self.mode].minZoom
  local fov = (45.0 / self.zoom) * 2.0
  self.camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", self.camCoords.x, self.camCoords.y, self.camCoords.z,
    self.camRotation.x,
    self.camRotation.y, self.camRotation.z,
    fov, false, 2)
  SetCamActive(self.camera, true)
  RenderScriptCams(true, false, 0, true, true)

  SetTimecycleModifier("default")
  SetTimecycleModifierStrength(0.0)

  SetNightvision(false)
  SetSeethrough(false)

  local mode = Config.Modes[self.mode]
  SetTimecycleModifier(mode.name)
  SetTimecycleModifierStrength(1.0)

  SetTimecycleModifierStrength(self.zoom)
  TaskStartScenarioInPlace(playerPed, Config.Scenario, 0, true)

  self:StartStateThread()
end

function Binoculars:StartStateThread()
  if self.stateTimer then return end

  self.stateTimer = SetTimeout(0, function()
    CreateThread(function()
      while self.inAction do
        if not self.camera then break end

        -- Update scaleforms
        self:UpdateScaleforms()

        -- Handle controls
        DisableHudAndControls()
        self:UpdateCamRotation()

        Wait(0)
      end
      self.stateTimer = nil
    end)
  end)
end

function Binoculars:UpdateScaleforms()
  -- Binoculars scaleform (centered)
  self.scaleform = lib.requestScaleformMovie('BINOCULARS')
  BeginScaleformMovieMethod(self.scaleform, 'SET_CAM_LOGO')
  ScaleformMovieMethodAddParamInt(0)
  EndScaleformMovieMethod()
  DrawScaleformMovie(self.scaleform, 0.5, 0.5, 1.0, 1.0, 255, 255, 255, 255, 0)
  -- Security camera scaleform
  if (self.useModes ~= nil and self.useModes ~= false) and Config.UseModes then
    self.camscaleform = lib.requestScaleformMovie(Config.BinocularsHud)
    BeginScaleformMovieMethod(self.camscaleform, 'SET_CAM_LOGO')
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()
    DrawScaleformMovie(self.camscaleform, Config.HudPos.x, Config.HudPos.y, Config.HudPos.w, Config.HudPos.h, 255, 255,
      255, 255, 0)
  end

  -- Buttons scaleform
  Utils:ShowHelpButtons(self.useModes)
end

function Binoculars:DeactivateBinoculars()
  self:Debug("info", "Deactivating binoculars")

  RenderScriptCams(false, false, 0, true, true)
  DestroyCam(self.camera, false)

  ClearTimecycleModifier()
  ClearPedTasks(PlayerPedId())

  SetScaleformMovieAsNoLongerNeeded(self.scaleform)
  if self.camscaleform then
    SetScaleformMovieAsNoLongerNeeded(self.camscaleform)
  end

  SetNightvision(false)
  SetSeethrough(false)

  Utils.cachedButtons = nil
end

function Binoculars:UpdateCamRotation()
  local rightAxisX = GetDisabledControlNormal(0, 220)
  local rightAxisY = GetDisabledControlNormal(0, 221)

  local sensitivity = 10.0 / self.zoom
  rightAxisX = rightAxisX * sensitivity
  rightAxisY = rightAxisY * sensitivity

  if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
    local newX = self.camRotation.x - rightAxisY
    local newZ = self.camRotation.z - rightAxisX

    if Config.CameraRotationClamp.x then
      newX = math.min(Config.CameraRotationClamp.y, math.max(Config.CameraRotationClamp.x, newX))
    end

    self.camRotation = vector3(newX, 0.0, newZ)
    SetCamRot(self.camera, self.camRotation.x, 0.0, self.camRotation.z, 2)
    SetEntityRotation(PlayerPedId(), 0.0, 0.0, self.camRotation.z, 2, true)
  end
end

function Binoculars:UpdateCamMode()
  if not self.inAction or not self.useModes or not Config.UseModes then
    return
  end
  PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)

  local mode = Config.Modes[self.mode]
  SetNightvision(false)
  SetSeethrough(false)

  if mode.name == "nightvision" then
    SetNightvision(true)
  else
    SetNightvision(false)
  end

  if mode.name == "thermalvision" then
    SetSeethrough(true)
  else
    SetSeethrough(false)
  end

  self:Debug("info", "Updated binoculars")
end

function Binoculars:UpdateCamZoom()
  if not self.inAction then return end

  local fov = (45.0 / self.zoom) * 2.0 -- Adjusted FOV calculation
  SetCamFov(self.camera, fov)
  self:Debug("info", "Updated binoculars zoom: " .. fov)
end

Binoculars.KeyAction = {
  previous = function()
    Binoculars:Debug("info", "Previous")
    Binoculars.mode = (#Config.Modes + Binoculars.mode - 2) % #Config.Modes + 1
    Binoculars:UpdateCamMode()
  end,
  next = function()
    Binoculars:Debug("info", "Next")
    Binoculars.mode = Binoculars.mode % #Config.Modes + 1
    Binoculars:UpdateCamMode()
  end,
  zoomIn = function()
    Binoculars:Debug("info", "Zoom in")
    Binoculars.zoom = math.min(Config.Modes[Binoculars.mode].maxZoom, Binoculars.zoom + 0.5) -- Changed increment to 0.5
    Binoculars:UpdateCamZoom()
  end,
  zoomOut = function()
    Binoculars:Debug("info", "Zoom out")
    Binoculars.zoom = math.max(Config.Modes[Binoculars.mode].minZoom, Binoculars.zoom - 0.5) -- Changed increment to 0.5
    Binoculars:UpdateCamZoom()
  end,
  exit = function()
    Binoculars:Debug("info", "Exit")
    Binoculars:ToggleBinoculars(false)
  end
}

function Binoculars:InitKeybinds()
  for action, value in pairs(Config.Controls) do
    local name = "force_binoculars_" .. action .. "3"
    -- Add spaces between uppercase letters and capitalize first letter
    -- local desc = action:gsub("(%u)", " %1"):gsub("^%s*(.)", string.upper):gsub("^%s+", "")
    local desc = locale(action)
    local func = self.KeyAction[action]

    self.cache.keybinds[action] = lib.addKeybind({
      name            = name,
      description     = desc,
      defaultKey      = value.key:upper(),
      defaultMapper   = value.defaultMapper or "keyboard",
      secondaryKey    = value.secondaryKey and value.secondaryKey:upper(),
      secondaryMapper = value.secondaryDefaultMapper or "keyboard",
      onReleased      = function()
        if not self.inAction then
          return
        end
        func()

        self:Debug("info", "Mode: " .. Config.Modes[self.mode].name)
        self:Debug("info", "Zoom: " .. self.zoom)
      end,
    })
  end
end

function Binoculars:InitCommands()
  self:Debug("info", "Initializing commands")

  if Config.Command then
    RegisterCommand(Config.Command, function()
      self:Debug("info", "Toggling binoculars")
      self:ToggleBinoculars(nil, false)
    end, false)
  end

  if Config.EnhancedCommand then
    RegisterCommand(Config.EnhancedCommand, function()
      self:Debug("info", "Toggling binoculars with modes")
      self:ToggleBinoculars(nil, true)
    end, false)
  end

  self:Debug("info", "Commands initialized")
end

---@param type string The type of the debug message (error, warn, info, verbose, debug).
---@param message string The debug message to print.
function Binoculars:Debug(type, message)
  if not Config.Debug then return end
  local func = lib.print[type] or lib.print.info
  func(message)
end

exports("ToggleBinoculars", function(...)
  Binoculars:Debug("info", "Toggling binoculars: " .. (Binoculars.inAction and " off" or " on"))
  Binoculars:ToggleBinoculars(...)
end)

exports("ActivateBinoculars", function(...)
  Binoculars:Debug("info", "Activating binoculars")
  Binoculars:ActivateBinoculars(...)
end)

exports("DeactivateBinoculars", function()
  Binoculars:Debug("info", "Deactivating binoculars")
  Binoculars:DeactivateBinoculars()
end)

exports("IsBinocularsActive", function()
  return Binoculars.inAction
end)

exports("GetBinocularsState", function()
  return Binoculars.inAction, Binoculars.mode, Binoculars.zoom
end)
