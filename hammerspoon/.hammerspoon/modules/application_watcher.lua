-- Application Watcher
local module = {}
module.logger = hs.logger.new("applicationWatcher.lua")

-- deactivatedApps array
_G.var = {}
_G.var.deactivatedApps = {}

-- NOTE: Use local function for any internal funciton not exported (not included as a part of the return)
local function applicationWatcher(appName, eventType, appObject)
  if eventType == hs.application.watcher.deactivated then
    table.insert(_G.var.deactivatedApps, appName)
    if #_G.var.deactivatedApps >= 5 then
      _G.var.deactivatedApps = {}
    end
  end
end

module.watcher = hs.application.watcher.new(applicationWatcher)

module.start = function()
  module.logger.i("Starting Application Watcher")
  module.watcher:start()
  return module
end

module.stop = function()
  module.logger.i("Stopping Application Watcher")
  module.watcher:stop()
  return module
end

module.start()

return module
