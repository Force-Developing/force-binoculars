if Config.Framework ~= "qbx" then
  return
end

function RegisterUsableItem(item, cb)
  exports.qbx_core:CreateUseableItem(item, cb)
end
