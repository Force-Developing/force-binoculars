if Config.Framework.name ~= "qbcore" then
  return
end

local QBCore = exports[Config.Framework.resource]:GetCoreObject()

function RegisterUsableItem(item, cb)
  QBCore.Functions.CreateUseableItem(item, cb)
end
