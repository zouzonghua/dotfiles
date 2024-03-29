local grid = require("hs.grid")
local hotkey = require("hs.hotkey")
local fnutils = require("hs.fnutils")
local application = require("hs.application")

local modifiers = { "ctrl", "alt", "cmd", "shift" }

grid.setMargins({ 0, 0 })

local applist = {
  { hotkey = "A", appname = "Alacritty" },
  { hotkey = "E", appname = "Emacs" },
  { hotkey = "G", appname = "Google Chrome" },
  { hotkey = "C", appname = "calibre" },
  { hotkey = "T", appname = "Telegram" },
  { hotkey = "W", appname = "WeChat" },
  { hotkey = "Q", appname = "QQ" },
  { hotkey = "Z", appname = "zoom.us" },
  { hotkey = "S", appname = "Spotify" },
  { hotkey = "L", appname = "Launchpad" },
  { hotkey = "F", appname = "Finder" },
  { hotkey = "B", appname = "Books" },
  { hotkey = "P", appname = "Preview" },
}

fnutils.each(applist, function(item)
  hotkey.bind(modifiers, item.hotkey, item.appname, function()
    application.launchOrFocus(item.appname)
    -- toggle_application(entry.appname)
  end)
end)

-- Toggle an application between being the frontmost app, and being hidden
-- local function toggle_application(_app)
--   local app = hs.appfinder.appFromName(_app)
--   if not app then
--     application.launchOrFocus(_app)
--     return
--   end
--   local mainwin = app:mainWindow()
--   if mainwin then
--     if mainwin == hs.window.focusedWindow() then
--       mainwin:application():hide()
--     else
--       mainwin:application():activate(true)
--       mainwin:application():unhide()
--       mainwin:focus()
--     end
--   else
--     application.launchOrFocus(_app)
--   end
-- end
