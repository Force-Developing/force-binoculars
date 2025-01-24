if Config.Framework.name ~= "qbx" then
  return
end

function RegisterUsableItem(item, cb)
  exports.qbx_core:CreateUseableItem(item, cb)
end
