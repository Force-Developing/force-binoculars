-- Runs when Config.Framework.name = "custom" (Config.Framework.resource: your framework's resource name, or "auto"
-- to run right away). With a resource name it runs once that resource has started, and again after every restart.
RegisterFramework("custom", function(resource)
  function RegisterUsableItem(item, cb)
    -- Implement your own usable item registration here
  end
end)
