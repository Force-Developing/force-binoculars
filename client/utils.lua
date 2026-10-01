Utils = {}

local function BuildButtons(useModes)
  local buttons = {}
  for k, v in pairs(Config.Controls) do
    local isModeControl = k == "previous" or k == "next"
    if not isModeControl or (useModes and Config.UseModes) then
      buttons[#buttons + 1] = {
        sort = v.sort or math.huge,
        text = locale(k),
        key = "~" .. v.name .. "~",
        secondaryKey = v.secondaryName and "~" .. v.secondaryName .. "~" or false
      }
    end
  end

  table.sort(buttons, function(a, b) return a.sort < b.sort end)
  return buttons
end

--- Fills the instructional_buttons scaleform once; draw it every frame afterwards.
function Utils:SetupHelpButtons(scaleform, useModes)
  PushScaleformMovieFunction(scaleform, 'CLEAR_ALL')
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, 'SET_CLEAR_SPACE')
  PushScaleformMovieFunctionParameterInt(200)
  PopScaleformMovieFunctionVoid()

  for k, v in ipairs(BuildButtons(useModes)) do
    PushScaleformMovieFunction(scaleform, 'SET_DATA_SLOT')
    PushScaleformMovieFunctionParameterInt(k - 1)

    if v.secondaryKey then
      PushScaleformMovieMethodParameterButtonName(v.secondaryKey)
    end
    PushScaleformMovieMethodParameterButtonName(v.key)
    PushScaleformMovieFunctionParameterString(v.text)

    PopScaleformMovieFunctionVoid()
  end

  PushScaleformMovieFunction(scaleform, 'DRAW_INSTRUCTIONAL_BUTTONS')
  PushScaleformMovieFunctionParameterInt(-1)
  PopScaleformMovieFunctionVoid()
end
