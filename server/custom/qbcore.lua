if Config.Framework ~= "qbcore" then
  return
end

local QBCore = exports[(Config.FrameworkResource == "auto" and "es_extended" or Config.FrameworkResource)]:getCoreObject()

function RegisterUsableItem(item, cb)
  QBCore.Functions.CreateUseableItem(item, cb)
end
