lib.versionCheck('Force-Developing/force-binoculars')

local latestVersionUrl =
"https://gist.githubusercontent.com/Force-Developing/3ef6cb4066ebc648b19dc43b47b4a23a/raw/b1b4a43cc1078309c71f1da8851009469eb46075/force-binoculars"
local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)

local function versionCheck()
  PerformHttpRequest(latestVersionUrl, function(err, response, headers)
    if err == 200 then
      local version, changelogs = response:match("<(.-)>(.-)<")
      if not version then
        version = response:match("<(.-)>")
        changelogs = response:match(">(.-)<")
      end
      if not version or not changelogs then
        lib.print.error("Failed to check for updates.")
        return
      end
      version = version:gsub("[<>]", "")
      changelogs = changelogs:gsub("%-", "\n-")

      local output = "-------------\n"
      output = output .. "Current Version: " .. currentVersion .. "\n"
      output = output .. "Latest Version: " .. version .. "\n"
      output = output .. "-------------\n"

      if currentVersion ~= version then
        output = output .. "A new version is available. Please update your resource.\n"
        output = output .. "Changelogs:\n" .. changelogs .. "\n"
      else
        output = output .. "You are running the latest version.\n"
      end

      output = output .. "-------------"
      lib.print.info(output)
    else
      lib.print.error("Failed to check for updates.")
    end
  end, 'GET', '', {
    ['Content-Type'] = 'application/json',
    ['User-Agent'] = 'Lua'
  })
end

CreateThread(function()
  versionCheck()
end)
