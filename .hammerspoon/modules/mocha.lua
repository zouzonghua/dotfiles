-- Prevent your computer from going to sleep

-----------------------------
--  Customization Options  --
-----------------------------

-- Use the modifiers + hotkey to prevent your computer from sleeping. Click
-- the menu bar icon to allow it to sleep again.
local modifiers = { "ctrl", "alt", "cmd" }
local hotkey = "M"


-------------------------------------------------------------------
--  Don't mess with this part unless you know what you're doing  --
-------------------------------------------------------------------

local caf = require "hs.caffeinate"

local menu
local isEnable = false

local function enable()
  caf.set("displayIdle", true, true)
  caf.set("systemIdle", true, true)
  caf.set("system", true, true)
  if not menu then
    menu = hs.menubar.new()
  end
  menu:returnToMenuBar()
  -- menu:setTitle("☕️")
  menu:setIcon("~/.hammerspoon/icon/caffeine-on.pdf")
  menu:setTooltip("Mocha")
  menu:setClickCallback(function() disable() end)
  isEnable = true
  hs.alert.show("disable sleep")
end

function disable()
  caf.set("displayIdle", false, false)
  caf.set("systemIdle", false, false)
  caf.set("system", false, false)
  isEnable = false
  hs.alert.show("enable sleep")
  menu:delete()
end

hs.hotkey.bind(modifiers, hotkey, function()
  if not isEnable then
    enable()
  else
    disable()
  end
end)
