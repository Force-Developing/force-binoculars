AddEventHandler("onResourceStop", function(resource)
  if resource ~= GetCurrentResourceName() then
    return
  end

  if Binoculars.inAction then
    Binoculars:ToggleBinoculars(false)
  end
end)

RegisterNetEvent("force-binoculars:client:toggleBinoculars")
AddEventHandler("force-binoculars:client:toggleBinoculars", function(toggle, useModes)
  Binoculars:ToggleBinoculars(toggle, useModes)
end)
