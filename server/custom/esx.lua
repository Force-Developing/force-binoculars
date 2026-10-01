if Config.Framework.name ~= "esx" then
  return
end

local ESX = exports[Config.Framework.resource]:getSharedObject()

function RegisterUsableItem(item, cb)
  ESX.RegisterUsableItem(item, cb)
end
