if Config.Framework.name ~= "qbx" then
  return
end

function RegisterUsableItem(item, cb)
  exports[Config.Framework.resource]:CreateUseableItem(item, cb)
end
