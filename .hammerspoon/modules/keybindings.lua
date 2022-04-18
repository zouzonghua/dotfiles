local wm = require("modules/window-management")
local hk = require("hs.hotkey")
local increaseSizeModifiers = { "shift", "cmd" }
local decreaseSizeModifiers = { "shift", "alt" }

-- * Key Binding Utility
--- Bind hotkey for window management.
-- @function windowBind
-- @param {table} hyper - hyper key set
-- @param { ...{key=value} } keyFuncTable - multiple hotkey and function pairs
--   @key {string} hotkey
--   @value {function} callback function
local function windowBind(hyper, keyFuncTable)
	for key, fn in pairs(keyFuncTable) do
		hk.bind(hyper, key, fn)
	end
end

-- * Move window to screen
-- windowBind({"ctrl", "alt"}, {
--   left = wm.throwLeft,
--   right = wm.throwRight
-- })
--
-- -- * Set Window Position on screen
-- windowBind({"ctrl", "alt", "cmd"}, {
--   m = wm.maximizeWindow,    -- ⌃⌥⌘ + M
--   c = wm.centerOnScreen,    -- ⌃⌥⌘ + C
--   left = wm.leftHalf,       -- ⌃⌥⌘ + ←
--   right = wm.rightHalf,     -- ⌃⌥⌘ + →
--   up = wm.topHalf,          -- ⌃⌥⌘ + ↑
--   down = wm.bottomHalf      -- ⌃⌥⌘ + ↓
-- })

-- * Windows-like cycle
-- windowBind({"ctrl", "alt", "cmd"}, {
--   u = wm.cycleLeft,          -- ⌃⌥⌘ + u
--   i = wm.cycleRight          -- ⌃⌥⌘ + i
-- })

-- * Set Window Resize
windowBind(increaseSizeModifiers, {
	h = wm.rightToLeft,
	l = wm.rightToRight,
	k = wm.bottomUp,
	j = wm.bottomDown,
})
-- * Set Window Resize
windowBind(decreaseSizeModifiers, {
  h = wm.leftToLeft,
  l = wm.leftToRight,
  k = wm.topUp,
  j = wm.topDown
})
