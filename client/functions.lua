Binoculars = {
  inAction = false,
  camera = nil,
  camCoords = vector3(0.0, 0.0, 0.0),
  camRotation = vector3(0.0, 0.0, 0.0),
  zoom = 5.0,
  mode = 1,
  useModes = false,
  session = 0,
  scaleforms = nil,
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
local TIMECYCLE_MODIFIER = "default"
local TIMECYCLE_STRENGTH = 1.0 -- SetTimecycleModifierStrength expects 0.0 - 1.0

local function DisableHudAndControls()
  HideHudAndRadarThisFrame()
  for _, component in ipairs(hudComponents) do
    HideHudComponentThisFrame(component)
  end

  DisableAllControlActions(2)
end

local function GetFov(zoom)
  -- Higher zoom (magnification) = lower FOV = more zoomed in
  return (45.0 / zoom) * 2.0
end

local function CanUseBinoculars(ped)
  return DoesEntityExist(ped)
      and not IsEntityDead(ped)
      and not IsPedInAnyVehicle(ped, false)
      and not IsPedRagdoll(ped)
      and not IsPedSwimming(ped)
end

-- ESC / P: the pause menu is disabled while the binoculars are open, so treat it as "close"
local PAUSE_CONTROLS = { 199, 200 }

local function IsPausePressed()
  for _, control in ipairs(PAUSE_CONTROLS) do
    if IsDisabledControlJustPressed(0, control) then return true end
  end
  return false
end

local function RequestScaleform(name)
  local ok, handle = pcall(lib.requestScaleformMovie, name)
  if ok and handle then
    return handle
  end

  Debug("error", "Failed to load scaleform: " .. name)
  return nil
end

--- @param state boolean|nil true = on, false = off, nil = toggle
--- @param useModes boolean|nil allow night/thermal vision modes
--- @return boolean active
function Binoculars:ToggleBinoculars(state, useModes)
  if state == nil then
    state = not self.inAction
  end

  if state then
    self:ActivateBinoculars(useModes)
  else
    self:DeactivateBinoculars()
  end

  Debug("info", "Binoculars toggled: " .. (self.inAction and "on" or "off"))
  return self.inAction
end

--- @param useModes boolean|nil allow night/thermal vision modes
--- @return boolean success
function Binoculars:ActivateBinoculars(useModes)
  if self.inAction then
    return true
  end

  Debug("info", "Activating binoculars")

  -- Not cache.ped: it still holds the old, deleted ped for up to 100 ms after a model change
  local ped = PlayerPedId()
  if not CanUseBinoculars(ped) then
    Debug("warn", "Player cannot use binoculars right now")
    return false
  end

  self.useModes = (useModes and Config.UseModes) and true or false
  self.mode = 1
  self.zoom = Config.Modes[self.mode].minZoom

  if not self:SetupCamera(ped) then
    Debug("error", "Failed to setup camera")
    return false
  end

  self.inAction = true
  self.session = (self.session or 0) + 1

  ToggleHud(false)
  self:InitializeEffects()
  TaskStartScenarioInPlace(ped, Config.Scenario, 0, true)
  self:StartStateThread(self.session)

  return true
end

function Binoculars:SetupCamera(playerPed)
  -- NOTE: rotation is negated from the gameplay cam; verify in-game before changing
  self.camRotation = -GetGameplayCamRot(2)
  self.camCoords = GetOffsetFromEntityInWorldCoords(playerPed,
    Config.CameraOffset.x,
    Config.CameraOffset.y,
    Config.CameraOffset.z
  )

  self.camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",
    self.camCoords.x, self.camCoords.y, self.camCoords.z,
    self.camRotation.x, self.camRotation.y, self.camRotation.z,
    GetFov(self.zoom), false, 2
  )

  if not DoesCamExist(self.camera) then
    self.camera = nil
    return false
  end

  SetCamActive(self.camera, true)
  RenderScriptCams(true, false, 0, true, true)
  return true
end

function Binoculars:InitializeEffects()
  SetTimecycleModifier(TIMECYCLE_MODIFIER)
  SetTimecycleModifierStrength(TIMECYCLE_STRENGTH)
  self:ApplyModeEffects()
end

function Binoculars:ApplyModeEffects()
  local name = Config.Modes[self.mode].name
  SetNightvision(name == "nightvision")
  SetSeethrough(name == "thermalvision")
end

function Binoculars:LoadScaleforms()
  local scaleforms = {
    binoculars = RequestScaleform("BINOCULARS"),
    hud = self.useModes and RequestScaleform(Config.BinocularsHud) or nil,
    buttons = RequestScaleform("instructional_buttons"),
  }

  for _, key in ipairs({ "binoculars", "hud" }) do
    local handle = scaleforms[key]
    if handle then
      BeginScaleformMovieMethod(handle, "SET_CAM_LOGO")
      ScaleformMovieMethodAddParamInt(0)
      EndScaleformMovieMethod()
    end
  end

  if scaleforms.buttons then
    Utils:SetupHelpButtons(scaleforms.buttons, self.useModes)
  end

  return scaleforms
end

local function ReleaseScaleforms(scaleforms)
  if not scaleforms then return end
  for _, handle in pairs(scaleforms) do
    SetScaleformMovieAsNoLongerNeeded(handle)
  end
end

local function DrawScaleforms(scaleforms)
  if scaleforms.binoculars then
    DrawScaleformMovie(scaleforms.binoculars, 0.5, 0.5, 1.0, 1.0, 255, 255, 255, 255, 0)
  end

  if scaleforms.hud then
    DrawScaleformMovie(scaleforms.hud, Config.HudPos.x, Config.HudPos.y, Config.HudPos.w, Config.HudPos.h,
      255, 255, 255, 255, 0)
  end

  if scaleforms.buttons then
    DrawScaleformMovieFullscreen(scaleforms.buttons, 36, 53, 61, 255, 0)
  end
end

function Binoculars:StartStateThread(session)
  CreateThread(function()
    -- Scaleforms are requested once per activation and released on deactivation
    local scaleforms = self:LoadScaleforms()
    if not self.inAction or self.session ~= session then
      ReleaseScaleforms(scaleforms)
      return
    end
    self.scaleforms = scaleforms

    while self.inAction and self.session == session and self.camera do
      if not CanUseBinoculars(PlayerPedId()) or IsPausePressed() then
        Debug("info", "Auto-exiting binoculars (dead, in vehicle, ragdoll, swimming or ESC)")
        self:DeactivateBinoculars()
        break
      end

      DrawScaleforms(scaleforms)
      self:UpdateCamRotation()
      DisableHudAndControls()

      Wait(0)
    end
  end)
end

--- @return boolean wasActive
function Binoculars:DeactivateBinoculars()
  if not self.inAction then
    return false
  end

  Debug("info", "Deactivating binoculars")
  self.inAction = false

  RenderScriptCams(false, false, 0, true, true)
  if self.camera then
    DestroyCam(self.camera, false)
    self.camera = nil
  end

  ReleaseScaleforms(self.scaleforms)
  self.scaleforms = nil

  ClearTimecycleModifier()
  SetNightvision(false)
  SetSeethrough(false)

  local ped = PlayerPedId()
  if DoesEntityExist(ped) and not IsEntityDead(ped) and not IsPedInAnyVehicle(ped, false) then
    ClearPedTasks(ped)
  end
  ClearPedSecondaryTask(ped)

  self.mode = 1
  self.useModes = false

  -- Last: it calls other resources, and the camera must be released even if one of them fails
  ToggleHud(true)

  return true
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
  if not self.inAction or not self.useModes then
    return
  end
  PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)

  self:ApplyModeEffects()

  -- Keep zoom within the new mode's limits
  local mode = Config.Modes[self.mode]
  self.zoom = math.max(mode.minZoom, math.min(mode.maxZoom, self.zoom))
  self:UpdateCamZoom()

  Debug("info", "Updated binoculars mode: " .. mode.name)
end

function Binoculars:UpdateCamZoom()
  if not self.inAction or not self.camera then return end

  local fov = GetFov(self.zoom)
  SetCamFov(self.camera, fov)
  Debug("info", "Updated binoculars zoom: " .. fov)
end

Binoculars.KeyAction = {
  previous = function()
    if not Binoculars.useModes then return end
    Debug("info", "Previous")
    Binoculars.mode = (#Config.Modes + Binoculars.mode - 2) % #Config.Modes + 1
    Binoculars:UpdateCamMode()
  end,
  next = function()
    if not Binoculars.useModes then return end
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

--- @param state boolean|nil true = on, false = off, nil = toggle
--- @param useModes boolean|nil allow night/thermal vision modes
--- @return boolean active
exports("ToggleBinoculars", function(state, useModes)
  return Binoculars:ToggleBinoculars(state, useModes)
end)

--- @param useModes boolean|nil allow night/thermal vision modes
--- @return boolean success
exports("ActivateBinoculars", function(useModes)
  return Binoculars:ToggleBinoculars(true, useModes)
end)

--- @return boolean wasActive
exports("DeactivateBinoculars", function()
  return Binoculars:DeactivateBinoculars()
end)

--- @return boolean active
exports("IsBinocularsActive", function()
  return Binoculars.inAction
end)

--- @return boolean active, integer modeIndex, number zoom
exports("GetBinocularsState", function()
  return Binoculars.inAction, Binoculars.mode, Binoculars.zoom
end)
