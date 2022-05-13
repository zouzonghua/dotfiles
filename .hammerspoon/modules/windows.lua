-- window management
local hotkey = require("hs.hotkey")
local window = require("hs.window")
local layout = require("hs.layout")
local alert = require("hs.alert")
local modifiers = { "ctrl", "alt", "shift" }


local function checkWin(callback)
  if window.focusedWindow() then
    callback()
  else
    alert.show("No active window")
  end
end

-- left half
-- +-----------------+
-- |        |        |
-- |  HERE  |        |
-- |        |        |
-- +-----------------+
hotkey.bind(modifiers, "h", function()
  checkWin(function()
    window.focusedWindow():moveToUnit(layout.left50)
  end)
end)

-- right half
-- +-----------------+
-- |        |        |
-- |        |  HERE  |
-- |        |        |
-- +-----------------+
hotkey.bind(modifiers, "l", function()
  checkWin(function()
    window.focusedWindow():moveToUnit(layout.right50)
  end)
end)

-- maximize window
-- +-----------------+
-- |                 |
-- |       HERE      |
-- |                 |
-- +-----------------+
hotkey.bind(modifiers, "k", function()
  checkWin(function()
    window.focusedWindow():maximize()
  end)
end)

-- center window
-- +-----------------+
-- |   +--------+    |
-- |   |  HERE  |    |
-- |   +--------+    |
-- +-----------------+
hotkey.bind(modifiers, "j", function()
  checkWin(function()
    window.focusedWindow():moveToUnit("[20,10,80,90]")
  end)
end)

-- left top quarter
-- +-----------------+
-- |  HERE  |        |
-- +--------+        |
-- |                 |
-- +-----------------+
hotkey.bind(modifiers, "y", function()
  checkWin(function()
    window.focusedWindow():moveToUnit("[0,0,50,50]")
  end)
end)

-- right bottom quarter
-- +-----------------+
-- |                 |
-- |        +--------|
-- |        |  HERE  |
-- +-----------------+
hotkey.bind(modifiers, "o", function()
  window.focusedWindow():moveToUnit("[50,50,100,100]")
end)

-- right top quarter
-- +-----------------+
-- |        |  HERE  |
-- |        +--------|
-- |                 |
-- +-----------------+
hotkey.bind(modifiers, "i", function()
  checkWin(function()
    window.focusedWindow():moveToUnit("[50,0,100,50]")
  end)
end)

-- left bottom quarter
-- +-----------------+
-- |                 |
-- +--------+        |
-- |  HERE  |        |
-- +-----------------+
hotkey.bind(modifiers, "u", function()
  checkWin(function()
    window.focusedWindow():moveToUnit("[0,50,50,100]")
  end)
end)
