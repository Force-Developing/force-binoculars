CreateThread(function()
  -- After every server file has loaded, so the framework files (server/custom) have registered themselves
  Wait(0)
  InitFramework(function()
    Binoculars:InitMain()
  end)
end)
