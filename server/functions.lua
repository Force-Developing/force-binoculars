Binoculars = {}

function Binoculars:InitFramework()
  if Config.Framework ~= "auto" then return end

  local frameworks = {
    { name = "es_extended", type = "esx" },
    { name = "qb-core",     type = "qbcore" },
    { name = "qbx-core",    type = "qbx" }
  }

  for _, fw in ipairs(frameworks) do
    if GetResourceState(fw.name) ~= "missing" then
      Config.Framework = fw.type
      return
    end
  end

  Config.Framework = "custom"
end

function Binoculars:InitMain()
  Binoculars:Debug("info", "Initializing main")

  self:InitItems()

  Binoculars:Debug("info", "Main initialized")
end

function Binoculars:InitItems()
  if Config.Item then
    Binoculars:Debug("info", "Registering item: " .. Config.Item)
    RegisterUsableItem(Config.Item, function(source)
      TriggerClientEvent("force-binoculars:client:toggleBinoculars", source, nil, false)
    end)
  end

  if Config.EnhancedItem then
    Binoculars:Debug("info", "Registering item: " .. Config.EnhancedItem)
    RegisterUsableItem(Config.EnhancedItem, function(source)
      TriggerClientEvent("force-binoculars:client:toggleBinoculars", source, nil, true)
    end)
  end
end

---@param type string The type of the debug message (error, warn, info, verbose, debug).
---@param message string The debug message to print.
function Binoculars:Debug(type, message)
  if not Config.Debug then return end
  local func = lib.print[type] or lib.print.info
  func(message)
end
