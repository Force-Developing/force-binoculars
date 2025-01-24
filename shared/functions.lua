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

function InitFramework()
  if not Config.Framework.name == "auto" then return end
  local frameworks = {
    { name = "esx",    resource = "es_extended" },
    { name = "qbx",    resource = "qbx_core" },
    { name = "qbcore", resource = "qb-core" }
  }

  Debug("info", "Initializing framework")
  for _, framework in ipairs(frameworks) do
    if IsResourceStartingOrStarted(framework.resource) then
      Config.Framework = framework
      return
    end

    if next(frameworks) == nil then
      Config.Framework = "custom"
    end
  end
  Debug("info", "Framework initialized: " .. Config.Framework.name)
end
