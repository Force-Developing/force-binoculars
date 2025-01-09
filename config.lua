Config = {}

Config.Debug = true
Config.Locale = "en"                          -- ar, de, en, es, fr, nl, pl, pt, ru, sv
Config.Framework = "auto"                     -- auto, esx, qbcore, qbx, custom
Config.FrameworkResource = "auto"             -- Resource name for the framework

Config.Item = "binoculars"                    -- Item name, set to false to disable item registration
Config.EnhancedItem = "binoculars_modes"      -- Enhanced item name, set to false to disable item registration
Config.Command = "binoculars"                 -- Command name, set to false to disable command registration
Config.EnhancedCommand = "binoculars_modes"   -- Enhanced command name, set to false to disable command registration

Config.CameraOffset = vector3(0.2, 0.2, 0.95) -- Adjusted to be more like holding binoculars
Config.CameraRotationClamp = {
  x = -45.0,                                  -- Limit up/down rotation
  y = 45.0,                                   -- Maximum rotation angle
}
Config.Scenario = "WORLD_HUMAN_BINOCULARS"

Config.UseModes = true
Config.BinocularsHud = "SUB_CAM"
Config.HudPos = { x = 0.5, y = 0.5, w = 1.2, h = 1.2 } -- Scaleform position and size

Config.Modes = {
  {
    name = "default",
    maxZoom = 30.0, -- Less zoomed out (wider FOV)
    minZoom = 5.0,  -- More zoomed in (narrower FOV)
  },
  {
    name = "nightvision",
    maxZoom = 30.0,
    minZoom = 5.0,
  },
  {
    name = "thermalvision",
    maxZoom = 30.0,
    minZoom = 5.0,
  }
}

Config.Controls = {
  previous = {
    key = "LEFT",
    name = "INPUT_CELLPHONE_LEFT",
    sort = 5
  },
  next = {
    key = "RIGHT",
    name = "INPUT_CELLPHONE_RIGHT",
    sort = 4
  },
  zoomIn = {
    key = "IOM_WHEEL_UP",
    secondaryKey = "W",
    name = "INPUT_CURSOR_SCROLL_UP",
    secondaryName = "INPUT_MOVE_UP_ONLY",
    defaultMapper = "MOUSE_WHEEL",
    sort = 3
  },
  zoomOut = {
    key = "IOM_WHEEL_DOWN",
    secondaryKey = "S",
    name = "INPUT_CURSOR_SCROLL_DOWN",
    secondaryName = "INPUT_MOVE_DOWN_ONLY",
    defaultMapper = "MOUSE_WHEEL",
    sort = 2
  },
  exit = {
    key = "BACK",
    name = "INPUT_CELLPHONE_CANCEL",
    sort = 1
  }
}
