Binoculars = {}

function Binoculars:InitMain()
  Debug("info", "Initializing main")

  self:InitItems()

  Debug("info", "Main initialized")
end

function Binoculars:InitItems()
  for _, item in ipairs(Config.Binoculars) do
    if item.item then
      Debug("info", "Registering item: " .. item.item)
      RegisterUsableItem(item.item, function(source)
        TriggerClientEvent("force-binoculars:client:toggleBinoculars", source, nil, item.modes)
      end)
    end
  end
end
