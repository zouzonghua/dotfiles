--- Pomodoro module

--------------------------------------------------------------------------------
-- Configuration variables
--------------------------------------------------------------------------------
local pom = {}
pom.bar = {
  indicator_height = 0.1, -- ratio from the height of the menubar (0..1)
  indicator_alpha = 0.3,
  indicator_in_all_spaces = true,
  color_time_remaining = hs.drawing.color.green,
  color_time_used = hs.drawing.color.red,

  c_left = hs.drawing.rectangle(hs.geometry.rect(0, 0, 0, 0)),
  c_used = hs.drawing.rectangle(hs.geometry.rect(0, 0, 0, 0)),
}

pom.config = {
  enable_color_bar = true,
  work_period_sec = 25 * 60,
  rest_period_sec = 5 * 60,
}

pom.var = {
  is_active = false,
  disable_count = 0,
  work_count = 0,
  curr_active_type = "work", -- {"work", "rest"}
  time_left = pom.config.work_period_sec,
  max_time_sec = pom.config.work_period_sec,
}

--------------------------------------------------------------------------------
-- Color bar for pomodoor
--------------------------------------------------------------------------------

local function pom_del_indicators()
  pom.bar.c_left:delete()
  pom.bar.c_used:delete()
end

local function pom_draw_on_menu(target_draw, screen, offset, width, fill_color)
  local screeng = screen:fullFrame()
  local screen_frame_height = screen:frame().y
  local screen_full_frame_height = screeng.y
  local height_delta = screen_frame_height - screen_full_frame_height
  local height = pom.bar.indicator_height * height_delta

  target_draw:setSize(hs.geometry.rect(screeng.x + offset, screen_full_frame_height, width, height))
  target_draw:setTopLeft(hs.geometry.point(screeng.x + offset, screen_full_frame_height))
  target_draw:setFillColor(fill_color)
  target_draw:setFill(true)
  target_draw:setAlpha(pom.bar.indicator_alpha)
  target_draw:setLevel(hs.drawing.windowLevels.overlay)
  target_draw:setStroke(false)
  if pom.bar.indicator_in_all_spaces then
    target_draw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
  end
  target_draw:show()
end

local function pom_draw_indicator(time_left, max_time)
  local main_screen = hs.screen.mainScreen()
  local screeng = main_screen:fullFrame()
  local time_ratio = time_left / max_time
  local width = math.ceil(screeng.w * time_ratio)
  local left_width = screeng.w - width

  pom_draw_on_menu(pom.bar.c_left, main_screen, left_width, width, pom.bar.color_time_remaining)
  pom_draw_on_menu(pom.bar.c_used, main_screen, 0, left_width, pom.bar.color_time_used)
end

--------------------------------------------------------------------------------

-- update display
local function pom_update_display()
  local time_min = math.floor((pom.var.time_left / 60))
  local time_sec = pom.var.time_left - (time_min * 60)
  local str = string.format("[%s|%02d:%02d|#%02d]", pom.var.curr_active_type, time_min, time_sec, pom.var.work_count)
  pom_menu:setTitle(str)
end

-- stop the clock
-- Stateful:
-- * Disabling once will pause the countdown
-- * Disabling twice will reset the countdown
-- * Disabling trice will shut down and hide the pomodoro timer
local function pom_disable()
  local pom_was_active = pom.var.is_active
  pom.var.is_active = false

  if pom.var.disable_count == 0 then
    if pom_was_active then
      pom_timer:stop()
    end
  elseif pom.var.disable_count == 1 then
    pom.var.time_left = pom.config.work_period_sec
    pom.var.curr_active_type = "work"
    pom_update_display()
  elseif pom.var.disable_count >= 2 then
    if pom_menu == nil then
      pom.var.disable_count = 2
      return
    end

    pom_menu:delete()
    pom_menu = nil
    pom_timer:stop()
    pom_timer = nil
    pom_del_indicators()
  end

  pom.var.disable_count = pom.var.disable_count + 1
end

-- focus last deactivated app
local function focusLastDeactivatedApp()
  local appfinder = require("hs.appfinder")
  if #_G.var.deactivatedApps ~= 0 then
    local name = _G.var.deactivatedApps[#_G.var.deactivatedApps]
    local app = appfinder.appFromName(name)
    local mainwin = app:mainWindow()
    mainwin:application():activate(true)
    mainwin:focus()
  end
end

-- update pomodoro timer
local function pom_update_time()
  if pom.var.is_active == false then
    return
  else
    pom.var.time_left = pom.var.time_left - 1

    if pom.var.time_left <= 0 then
      pom_disable()
      if pom.var.curr_active_type == "work" then
        -- hs.alert.show("Work Complete!", 2)
        -- hs.alert.show("请放下手上的工作，去休息一下！！")
        callbackFn = function(result)
          print("Callback Result: " .. result)
          if result == "去休息" then
            pom.var.work_count = pom.var.work_count + 1
            pom.var.curr_active_type = "rest"
            pom.var.time_left = pom.config.rest_period_sec
            pom.var.max_time_sec = pom.config.rest_period_sec
            pom_enable()
            focusLastDeactivatedApp()
          elseif result == "继续干" then
            pom.var.curr_active_type = "work"
            pom.var.time_left = pom.config.work_period_sec
            pom.var.max_time_sec = pom.config.work_period_sec
            pom_enable()
            focusLastDeactivatedApp()
            hs.alert.show("请注意休息啊", 5)
          end
        end
        hs.dialog.alert(
          835,
          350,
          callbackFn,
          "Message",
          "请放下手上的工作，去休息一下！！",
          "去休息",
          "继续干",
          "NSCriticalAlertStyle"
        )
        hs.focus()
      else
        -- hs.alert.show("Done resting", 2)
        -- hs.alert.show("请开始愉快的工作吧！！")
        callbackFn = function(result)
          print("Callback Result: " .. result)
          if result == "开始工作" then
            pom.var.curr_active_type = "work"
            pom.var.time_left = pom.config.work_period_sec
            pom.var.max_time_sec = pom.config.work_period_sec
            pom_enable()
            focusLastDeactivatedApp()
          end
        end
        hs.dialog.alert(835, 350, callbackFn, "Message", "请开始愉快的工作吧！！", "开始工作")
        hs.focus()
      end
    end

    -- draw color bar indicator, if enabled.
    if pom.config.enable_color_bar == true then
      pom_draw_indicator(pom.var.time_left, pom.var.max_time_sec)
    end
  end
end

-- update menu display
local function pom_update_menu()
  pom_update_time()
  pom_update_display()
end

local function pom_create_menu(pom_origin)
  if pom_menu == nil then
    pom_menu = hs.menubar.new()
    pom.bar.c_left = hs.drawing.rectangle(hs.geometry.rect(0, 0, 0, 0))
    pom.bar.c_used = hs.drawing.rectangle(hs.geometry.rect(0, 0, 0, 0))
  end
end

-- start the pomodoro timer
function pom_enable()
  pom.var.disable_count = 0
  if pom.var.is_active then
    return
  end

  pom_create_menu()
  pom_timer = hs.timer.new(1, pom_update_menu)

  pom.var.is_active = true
  pom_timer:start()
end

-- reset work count
-- TODO - reset automatically every day
function pom_reset_work()
  pom.var.work_count = 0
end

-- Use examples:

-- init pomodoro -- show menu immediately
-- pom_create_menu()
-- pom_update_menu()

local modifiers = { "ctrl" }

-- show menu only on first pom_enable
hs.hotkey.bind(modifiers, "9", "pomodoor on", function()
  pom_enable()
end)
hs.hotkey.bind(modifiers, "0", "pomodoor off", function()
  pom_disable()
end)
hs.hotkey.bind(modifiers, "-", "pomodoor reset", function()
  pom_reset_work()
end)
