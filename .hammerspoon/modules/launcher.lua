local hotkey = require("hs.hotkey")
local grid = require("hs.grid")
local window = require("hs.window")
local application = require("hs.application")
local appfinder = require("hs.appfinder")
local fnutils = require("hs.fnutils")

local modifiers = { "ctrl", "alt" }

grid.setMargins({ 0, 0 })

applist = {
	{ hotkey = "A", appname = "Alacritty" },
	{ hotkey = "G", appname = "Google Chrome" },
	{ hotkey = "T", appname = "Telegram Desktop" },
	{ hotkey = "W", appname = "WeChat" },
	{ hotkey = "Q", appname = "QQ" },
	{ hotkey = "N", appname = "NeteaseMusic" },
	{ hotkey = "Z", appname = "zoom.us" },

	{ hotkey = "L", appname = "Launchpad" },
	{ hotkey = "F", appname = "Finder" },
}

fnutils.each(applist, function(item)
	hotkey.bind(modifiers, item.hotkey, item.appname, function()
		application.launchOrFocus(item.appname)
		-- toggle_application(entry.appname)
	end)
end)

-- Toggle an application between being the frontmost app, and being hidden
function toggle_application(_app)
	local app = appfinder.appFromName(_app)
	if not app then
		application.launchOrFocus(_app)
		return
	end
	local mainwin = app:mainWindow()
	if mainwin then
		if mainwin == window.focusedWindow() then
			mainwin:application():hide()
		else
			mainwin:application():activate(true)
			mainwin:application():unhide()
			mainwin:focus()
		end
	else
		application.launchOrFocus(_app)
	end
end
