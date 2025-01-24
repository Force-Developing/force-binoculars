if Config.Framework ~= "qbcore" then
  return
end

local QBCore = exports[(Config.Framework.resource == "auto" and "es_extended" or Config.Framework.resource)]
    :getCoreObject()

function RegisterUsableItem(item, cb)
  QBCore.Functions.CreateUseableItem(item, cb)
end
