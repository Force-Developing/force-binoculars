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
  message = tostring(message)
  -- Only format with arguments: messages often embed error text that can contain '%'
  if select("#", ...) > 0 then
    local ok, formatted = pcall(string.format, message, ...)
    if ok then message = formatted end
  end
  fn(message)
end

local RESOURCE = GetCurrentResourceName()

--- Prints to the console regardless of Config.Debug (setup problems must always be visible).
--- @param level "error"|"warn"|"info"
function Log(level, message)
  local color = level == "error" and "^1" or level == "warn" and "^3" or "^2"
  print(("%s[%s] %s^7"):format(color, RESOURCE, tostring(message)))
end

-- qbx_core before qb-core: qbx_core `provide`s qb-core, so GetResourceState('qb-core') is "started" on QBox too
local supportedFrameworks = {
  { name = "qbx",    resource = "qbx_core" },
  { name = "esx",    resource = "es_extended" },
  { name = "qbcore", resource = "qb-core" },
}

local function getDefaultResource(name)
  for _, framework in ipairs(supportedFrameworks) do
    if framework.name == name then
      return framework.resource
    end
  end
end

local frameworkInits = {}

--- Server framework files (server/custom) register their setup here. It runs once the framework is known and
--- running, and again whenever the framework resource restarts (its usable items are gone then).
--- @param name string "esx" | "qbcore" | "qbx" | "custom"
--- @param init fun(resource: string|false) defines RegisterUsableItem(item, cb)
function RegisterFramework(name, init)
  frameworkInits[name] = frameworkInits[name] or {}
  table.insert(frameworkInits[name], init)
end

local function IsInstalled(resource)
  local state = GetResourceState(resource)
  return state ~= "missing" and state ~= "unknown"
end

--- First running framework, otherwise nil and the frameworks that are installed but not started yet
local function FindRunning()
  for _, framework in ipairs(supportedFrameworks) do
    if IsResourceStartingOrStarted(framework.resource) then return framework end
  end
  local waiting = {}
  for _, framework in ipairs(supportedFrameworks) do
    if IsInstalled(framework.resource) then waiting[#waiting + 1] = framework.resource end
  end
  return nil, waiting
end

--- Runs the framework files' setup and then onReady(). With a framework resource it waits until that resource has
--- started (no time limit, warning every 10 s) and runs again after every restart of it.
local function Activate(onReady)
  local name, resource = Config.Framework.name, Config.Framework.resource

  --- @return boolean ok, string|nil err
  local function setup()
    for _, init in ipairs(frameworkInits[name] or {}) do
      local ok, err = pcall(init, resource)
      if not ok then
        return false, ("Framework file for '%s' failed: %s"):format(name, tostring(err))
      end
    end
    local ok, err = pcall(onReady)
    if not ok then Log("error", err) end
    return true
  end

  if not resource then
    local ok, err = setup()
    if not ok then Log("error", err) end
    return
  end

  local loading = false
  local function load()
    if loading then return end
    loading = true
    CreateThread(function()
      local nextWarning = GetGameTimer() + 10000
      while true do
        local ok, err = false, nil
        if GetResourceState(resource) == "started" then ok, err = setup() end
        if ok then break end
        if GetGameTimer() >= nextWarning then
          Log("error", err or ("Waiting for %s to start. Ensure it before %s in server.cfg."):format(resource, RESOURCE))
          nextWarning = GetGameTimer() + 10000
        end
        Wait(500)
      end
      loading = false
    end)
  end

  load()
  AddEventHandler("onServerResourceStart", function(started)
    if started == resource then load() end
  end)
end

--- Server only. Decides the framework (Config.Framework, or detected) and calls onReady once the framework's
--- usable-item function is set up, and again after the framework restarts. A framework that is installed but not
--- started yet is waited for without a time limit, with a red warning every 10 seconds.
--- @param onReady function
function InitFramework(onReady)
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
    return Activate(onReady)
  end

  local function resolved(framework)
    if framework then
      Config.Framework = { name = framework.name, resource = framework.resource }
      Debug("info", "Framework initialized: " .. framework.name)
      return Activate(onReady)
    end

    Config.Framework = { name = "standalone", resource = false }
    Log("warn", "No supported framework detected (es_extended, qbx_core, qb-core). " ..
      "Usable items will not be registered; commands still work.")
  end

  local framework, waiting = FindRunning()
  if framework or #waiting == 0 then return resolved(framework) end

  CreateThread(function()
    local nextWarning = GetGameTimer() + 10000
    while true do
      Wait(250)
      framework, waiting = FindRunning()
      if framework or #waiting == 0 then return resolved(framework) end
      if GetGameTimer() >= nextWarning then
        Log("error", ("Waiting for the framework (%s) to start. Ensure it before %s in server.cfg, remove it if you " ..
          "don't use it, or set Config.Framework.name."):format(table.concat(waiting, ", "), RESOURCE))
        nextWarning = GetGameTimer() + 10000
      end
    end
  end)
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
      -- A HUD version without this export must not break opening or closing the binoculars
      local ok, err = pcall(function()
        if hud.export then
          exports[hud.name][hud.export](nil, toggle)
        elseif hud.eventOn and hud.eventOff then
          TriggerEvent(toggle and hud.eventOn or hud.eventOff)
        end
      end)
      if not ok then
        Debug("warn", ("Toggling the HUD of %s failed: %s"):format(hud.name, tostring(err)))
      end
    end
  end
end
