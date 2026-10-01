function IsResourceStartingOrStarted(resource)
  return GetResourceState(resource) == "starting" or GetResourceState(resource) == "started"
end

function Debug(level, message, ...)
  if not Config.Debug then return end

  local levels = {
    error = function(msg) lib.print.error(msg) end,
    warn = function(msg) lib.print.warn(msg) end,
    info = function(msg) lib.print.info(msg) end,
    debug = function(msg) lib.print.debug(msg) end
  }

  local fn = levels[level] or levels.info
  fn(string.format(message, ...))
end

local supportedFrameworks = {
  { name = "esx",    resource = "es_extended" },
  { name = "qbx",    resource = "qbx_core" },
  { name = "qbcore", resource = "qb-core" },
}

local function getDefaultResource(name)
  for _, framework in ipairs(supportedFrameworks) do
    if framework.name == name then
      return framework.resource
    end
  end
end

function InitFramework()
  local configured = type(Config.Framework) == "table" and Config.Framework or {}
  local name = configured.name or "auto"
  local resource = configured.resource or "auto"

  Debug("info", "Initializing framework")

  if name ~= "auto" then
    if resource == "auto" then
      resource = getDefaultResource(name) or false
    end

    Config.Framework = { name = name, resource = resource }
    Debug("info", "Framework initialized: " .. name)
    return
  end

  for _, framework in ipairs(supportedFrameworks) do
    if IsResourceStartingOrStarted(framework.resource) then
      Config.Framework = { name = framework.name, resource = framework.resource }
      Debug("info", "Framework initialized: " .. framework.name)
      return
    end
  end

  Config.Framework = { name = "standalone", resource = false }
  lib.print.warn("No supported framework detected (es_extended, qbx_core, qb-core). " ..
    "Usable items will not be registered; commands still work.")
end

function ToggleHud(toggle)
  local huds = {
    { name = "vms_hud",   export = "Display" },
    { name = "esx_hud",   export = "HudToggle" },
    { name = "mHud",      eventOn = "mHud:ShowHud", eventOff = "mHud:HideHud" },
    { name = "17mov_Hud", export = "ToggleDisplay" },
  }

  for _, hud in ipairs(huds) do
    if IsResourceStartingOrStarted(hud.name) then
      if hud.export then
        exports[hud.name][hud.export](toggle)
      elseif hud.eventOn and hud.eventOff then
        TriggerEvent(toggle and hud.eventOn or hud.eventOff)
      end
    end
  end
end
