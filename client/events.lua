AddEventHandler("onResourceStop", function(resource)
  if resource ~= GetCurrentResourceName() then
    return
  end

  if Binoculars.inAction then
    Binoculars:ToggleBinoculars(false)
  end
end)
