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
  cache = {
    keybinds = {},
    commands = {}
  },
}

function Binoculars:InitMain()
  Debug("info", "Initializing main thread")

  self:InitKeybinds()
  self:InitCommands()

  Debug("info", "Main thread initialized")
end

local hudComponents = { 19, 1, 2, 3, 4, 13, 11, 12, 15, 18 }

local function DisableHudAndControls()
  HideHudAndRadarThisFrame()
  for _, component in ipairs(hudComponents) do
    HideHudComponentThisFrame(component)
  end

  DisableAllControlActions(2)
end

function Binoculars:ToggleBinoculars(toggle, useModes)
  self.inAction = toggle or not self.inAction
  Debug("info", "Binoculars toggled: " .. (self.inAction and "on" or "off"))

  if self.inAction then
    self:ActivateBinoculars(useModes)
  else
    self:DeactivateBinoculars()
  end
end

function Binoculars:ActivateBinoculars(useModes)
  Debug("info", "Activating binoculars")

  local playerPed = PlayerPedId()
  if not DoesEntityExist(playerPed) then
    Debug("error", "Failed to get player ped")
    return false
  end

  self.useModes = useModes
  ToggleHud(false)

  local success = self:SetupCamera(playerPed)
  if not success then
    Debug("error", "Failed to setup camera")
    return false
  end

  self:InitializeEffects()
  TaskStartScenarioInPlace(playerPed, Config.Scenario, 0, true)
  self:StartStateThread()

  return true
end

function Binoculars:SetupCamera(playerPed)
  self.camRotation = -GetGameplayCamRot(2)
  self.camCoords = GetOffsetFromEntityInWorldCoords(playerPed,
    Config.CameraOffset.x,
    Config.CameraOffset.y,
    Config.CameraOffset.z
  )

  self.zoom = Config.Modes[self.mode].minZoom
  local fov = (45.0 / self.zoom) * 2.0

  self.camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",
    self.camCoords.x, self.camCoords.y, self.camCoords.z,
    self.camRotation.x, self.camRotation.y, self.camRotation.z,
    fov, false, 2
  )

  if not DoesCamExist(self.camera) then
    return false
  end

  SetCamActive(self.camera, true)
  RenderScriptCams(true, false, 0, true, true)
  return true
end

function Binoculars:InitializeEffects()
  SetTimecycleModifier("default")
  SetTimecycleModifierStrength(0.0)

  SetNightvision(false)
  SetSeethrough(false)

  local mode = Config.Modes[self.mode]
  SetTimecycleModifier(mode.name)
  SetTimecycleModifierStrength(1.0)

  SetTimecycleModifierStrength(self.zoom)
end

function Binoculars:StartStateThread()
  CreateThread(function()
    while self.inAction do
      if not self.camera then break end

      self:UpdateState()

      Wait(4)
    end
  end)
end

function Binoculars:UpdateState()
  self:UpdateScaleforms()
  self:UpdateCamRotation()
  DisableHudAndControls()
end

function Binoculars:UpdateScaleforms()
  -- Binoculars scaleform (centered)
  if not HasScaleformMovieLoaded(self.scaleform) then
    self.scaleform = lib.requestScaleformMovie('BINOCULARS')
  end
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
  Debug("info", "Deactivating binoculars")
  ToggleHud(true)

  RenderScriptCams(false, false, 0, true, true)
  DestroyCam(self.camera, false)

  ClearTimecycleModifier()

  SetScaleformMovieAsNoLongerNeeded(self.scaleform)
  if self.camscaleform then
    SetScaleformMovieAsNoLongerNeeded(self.camscaleform)
  end

  SetNightvision(false)
  SetSeethrough(false)

  local playerPed = PlayerPedId()
  ClearPedTasks(playerPed)
  ClearPedSecondaryTask(playerPed)

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

  Debug("info", "Updated binoculars")
end

function Binoculars:UpdateCamZoom()
  if not self.inAction then return end

  local fov = (45.0 / self.zoom) * 2.0
  SetCamFov(self.camera, fov)
  Debug("info", "Updated binoculars zoom: " .. fov)
end

Binoculars.KeyAction = {
  previous = function()
    Debug("info", "Previous")
    Binoculars.mode = (#Config.Modes + Binoculars.mode - 2) % #Config.Modes + 1
    Binoculars:UpdateCamMode()
  end,
  next = function()
    Debug("info", "Next")
    Binoculars.mode = Binoculars.mode % #Config.Modes + 1
    Binoculars:UpdateCamMode()
  end,
  zoomIn = function()
    Debug("info", "Zoom in")
    Binoculars.zoom = math.min(Config.Modes[Binoculars.mode].maxZoom, Binoculars.zoom + 0.5)
    Binoculars:UpdateCamZoom()
  end,
  zoomOut = function()
    Debug("info", "Zoom out")
    Binoculars.zoom = math.max(Config.Modes[Binoculars.mode].minZoom, Binoculars.zoom - 0.5)
    Binoculars:UpdateCamZoom()
  end,
  exit = function()
    Debug("info", "Exit")
    Binoculars:ToggleBinoculars(false)
  end
}

function Binoculars:InitKeybinds()
  for action, value in pairs(Config.Controls) do
    local name = "force_binoculars_" .. action .. "3"
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

        Debug("info", "Mode: " .. Config.Modes[self.mode].name)
        Debug("info", "Zoom: " .. self.zoom)
      end,
    })
  end
end

function Binoculars:InitCommands()
  Debug("info", "Initializing commands")

  for _, command in pairs(Config.Binoculars) do
    if command.command then
      self.cache.commands[command.command] = command.modes
      RegisterCommand(command.command, function()
        Debug("info", "Toggling binoculars")
        self:ToggleBinoculars(nil, command.modes)
      end, false)
    end
  end

  Debug("info", "Commands initialized")
end

exports("ToggleBinoculars", function(...)
  Debug("info", "Toggling binoculars: " .. (Binoculars.inAction and " off" or " on"))
  Binoculars:ToggleBinoculars(...)
end)

exports("ActivateBinoculars", function(...)
  Debug("info", "Activating binoculars")
  Binoculars:ActivateBinoculars(...)
end)

exports("DeactivateBinoculars", function()
  Debug("info", "Deactivating binoculars")
  Binoculars:DeactivateBinoculars()
end)

exports("IsBinocularsActive", function()
  return Binoculars.inAction
end)

exports("GetBinocularsState", function()
  return Binoculars.inAction, Binoculars.mode, Binoculars.zoom
end)
