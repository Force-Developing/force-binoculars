Binoculars = {}

function Binoculars:InitMain()
  Binoculars:Debug("info", "Initializing main")


  Binoculars:Debug("info", "Main initialized")
end

---@param type string The type of the debug message (error, warn, info, verbose, debug).
---@param message string The debug message to print.
function Binoculars:Debug(type, message)
  if not Config.Debug then return end
  local func = lib.print[type] or lib.print.info
  func(message)
end
