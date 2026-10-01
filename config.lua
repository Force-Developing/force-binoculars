Config = {}

Config.Debug = false -- Default to false in production
Config.Locale = "en" -- ar, de, en, es, fr, nl, pl, pt, ru, sv

Config.Framework = {
  name = "auto",    -- auto, esx, qbcore, qbx, custom (auto falls back to standalone: commands only)
  resource = "auto" -- framework resource name, "auto" = es_extended / qb-core / qbx_core
}

Config.Binoculars = {
  {
    item = "binoculars",    -- item name or false to disable
    command = "binoculars", -- command name or false to disable
    modes = false,          -- modes: (default)
  },
  {
    item = "binoculars_modes", -- item name or false to disable
    command = false,           -- command name or false to disable (off by default: a public command would bypass the item)
    modes = true,                 -- modes: (default, nightvision, thermalvision)
  }
}

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
    -- Zoom is a magnification factor, camera FOV = 90 / zoom
    -- Higher value = lower FOV = more zoomed in; lower value = wider view
    maxZoom = 30.0, -- Most zoomed in (FOV 3.0)
    minZoom = 5.0,  -- Widest view, used when the binoculars open (FOV 18.0)
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
