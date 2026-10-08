-- Runs once force-binoculars knows the framework is "qbx" and it has started (again after every restart)
RegisterFramework("qbx", function(resource)
  function RegisterUsableItem(item, cb)
    exports[resource]:CreateUseableItem(item, cb)
  end
end)
