Utils = {
  cachedButtons = nil
}

function Utils:InitCacheButtons(useModes)
  self.cachedButtons = {}
  for k, v in pairs(Config.Controls) do
    if (k == "previous" or k == "next") and (useModes == nil or useModes == false) or not Config.UseModes then
      goto continue
    end
    -- local calcText = k:gsub("(%u)", " %1"):gsub("^%s*(.)", string.upper):gsub("^%s+", "")
    -- local text = calcText
    local text = locale(k)
    self.cachedButtons[v.sort or #self.cachedButtons + 1] = {
      text = text,
      key = "~" .. v.name .. "~",
      secondaryKey = (v.secondaryName) and "~" .. v.secondaryName .. "~" or false
    }
    ::continue::
  end
  return self.cachedButtons
end

function Utils:ShowHelpButtons(useModes)
  local buttons = Utils.cachedButtons or Utils:InitCacheButtons(useModes)
  if not buttons then return end
  local scaleform = RequestScaleformMovie('instructional_buttons')

  while not HasScaleformMovieLoaded(scaleform) do
    Wait(0)
  end

  PushScaleformMovieFunction(scaleform, 'CLEAR_ALL')
  PushScaleformMovieFunction(scaleform, 'SET_CLEAR_SPACE')
  PushScaleformMovieFunctionParameterInt(200)
  PopScaleformMovieFunctionVoid()

  for k, v in ipairs(self.cachedButtons) do
    PushScaleformMovieFunction(scaleform, 'SET_DATA_SLOT')
    PushScaleformMovieFunctionParameterInt(k - 1)

    if v.secondaryKey then
      PushScaleformMovieMethodParameterButtonName(v.secondaryKey)
      PushScaleformMovieMethodParameterButtonName(v.key)
      PushScaleformMovieFunctionParameterString(v.text)
    else
      PushScaleformMovieMethodParameterButtonName(v.key)
      PushScaleformMovieFunctionParameterString(v.text)
    end

    PopScaleformMovieFunctionVoid()
  end

  PushScaleformMovieFunction(scaleform, 'DRAW_INSTRUCTIONAL_BUTTONS')
  PushScaleformMovieFunctionParameterInt(-1)
  PopScaleformMovieFunctionVoid()
  DrawScaleformMovieFullscreen(scaleform, 36, 53, 61, 255, 0)
end
