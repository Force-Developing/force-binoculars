if Config.Framework ~= "esx" then
  return
end

local ESX = exports[(Config.FrameworkResource == "auto" and "es_extended" or Config.FrameworkResource)]:getSharedObject()

function RegisterUsableItem(item, cb)
  ESX.RegisterUsableItem(item, cb)
end
