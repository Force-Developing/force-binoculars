Binoculars = {}

function Binoculars:InitFramework()
  if Config.Framework ~= "auto" then
    return
  end

  if GetResourceState("es_extended") ~= "missing" then
    Config.Framework = "esx"
  elseif GetResourceState("qb-core") ~= "missing" then
    Config.Framework = "qbcore"
  elseif GetResourceState("qbx-core") ~= "missing" then
    Config.Framework = "qbx"
  else
    Config.Framework = "custom"
  end
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
