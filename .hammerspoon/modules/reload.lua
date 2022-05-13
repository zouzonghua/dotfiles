--- ---------------------------------------------------------------------------
--                            ** For Debug **                                --
--- ---------------------------------------------------------------------------
local modifiers = { "ctrl", "alt", "shift" }
local hotkey = "R"

local function reloadConfig(files)
  local doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
    hs.alert.show("Hammerspoon Config Reloaded")
  end
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- Well, sometimes auto-reload is not working, you know u.u
hs.hotkey.bind(modifiers, hotkey, function()
  hs.reload()
end)

hs.alert.show("Hammerspoon Config Reloaded")
