local ModifierHandler = {}


function ModifierHandler:start(appName)
  print(appName)
  self.appName = appName
  local flagsChanged = hs.eventtap.event.types.flagsChanged
  self.controlTapWatcher = hs.eventtap.new({ flagsChanged }, function(evt)
    return self:modifierWarchr(evt)
  end)
  self.controlTapWatcher:start()

end

function ModifierHandler:modifierWarchr(evt)
  local flags = evt:getFlags()
  local onlyCmdPressed = false
  local onlyCtrlPressed = false
  for k, v in pairs(flags) do
    onlyCmdPressed = v and k == "cmd"
    if not onlyCmdPressed then break end
    onlyCtrlPressed = v and k == "ctrl"
    if not onlyCtrlPressed then break end
  end

  if onlyCmdPressed then
    print("cmd keyhandler on")
    self.onlyCmdPressed = true
  elseif not next(flags) then
    self.onlyCmdPressed = false
    print("cmd keyhandler off")
  end

  if onlyCtrlPressed then
    print("ctrl keyhandler on")
    self.onlyCtrlPressed = true
  elseif not next(flags) then
    self.onlyCtrlPressed = false
    print("ctrl keyhandler off")
  end

  if (self.appName == "Alacritty") then

    if onlyCmdPressed then
      -- hs.eventtap.keyStroke('ctrl', '', 0)
      print('1')
    end
  end

end

function ModifierHandler:exit()
  self.controlTapWatcher:stop()
end

return ModifierHandler
