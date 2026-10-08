-- Runs once force-binoculars knows the framework is "esx" and it has started (again after every restart)
RegisterFramework("esx", function(resource)
  local ESX = exports[resource]:getSharedObject()

  function RegisterUsableItem(item, cb)
    ESX.RegisterUsableItem(item, cb)
  end
end)
