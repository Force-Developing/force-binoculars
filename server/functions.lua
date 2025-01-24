Binoculars = {}

function Binoculars:InitMain()
  Debug("info", "Initializing main")

  self:InitItems()

  Debug("info", "Main initialized")
end

function Binoculars:InitItems()
  if Config.Item then
    Debug("info", "Registering item: " .. Config.Item)
    RegisterUsableItem(Config.Item, function(source)
      TriggerClientEvent("force-binoculars:client:toggleBinoculars", source, nil, false)
    end)
  end

  if Config.EnhancedItem then
    Debug("info", "Registering item: " .. Config.EnhancedItem)
    RegisterUsableItem(Config.EnhancedItem, function(source)
      TriggerClientEvent("force-binoculars:client:toggleBinoculars", source, nil, true)
    end)
  end
end
