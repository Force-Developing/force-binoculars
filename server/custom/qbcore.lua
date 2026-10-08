-- Runs once force-binoculars knows the framework is "qbcore" and it has started (again after every restart)
RegisterFramework("qbcore", function(resource)
  local QBCore = exports[resource]:GetCoreObject()

  function RegisterUsableItem(item, cb)
    QBCore.Functions.CreateUseableItem(item, cb)
  end
end)
