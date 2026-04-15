local spoon_path = os.getenv("HOME") .. "/.hammerspoon/Spoons/PaperWM.spoon"
if hs.fs.attributes(spoon_path, "mode") == nil then
  hs.alert.show("PaperWM.spoon is missing: " .. spoon_path)
  return
end

local spoon_path = os.getenv("HOME") .. "/.hammerspoon/Spoons/SpaceIndicator.spoon"
if hs.fs.attributes(spoon_path, "mode") == nil then
  hs.alert.show("SpaceIndicator.spoon is missing: " .. spoon_path)
  return
end

SpaceIndicator = hs.loadSpoon("SpaceIndicator")
if SpaceIndicator then
  SpaceIndicator:start()
end

PaperWM = hs.loadSpoon("PaperWM")
if not PaperWM then
  hs.alert.show("Failed to load PaperWM")
  return
end

PaperWM.window_gap = { top = 5, bottom = 5, left = 5, right = 5 }

PaperWM.window_ratios = { 1/3, 1/2, 2/3, 1/1 }

-- enable infinite loop scrolling for focus left/right/up/down
PaperWM.infinite_loop_window = true

PaperWM:bindHotkeys({

    -- position and resize focused window
    center_window        = {{"alt"}, "c"},
    cycle_width          = {{"alt"}, "r"},
    reverse_cycle_width  = {{"alt", "shift"}, "r"},

    -- switch to a new focused window in tiled grid
    focus_left  = {{"alt"}, "tab"},
    focus_right = {{"alt", "cmd"}, "l"},

    -- switch windows by cycling forward/backward
    -- (forward = down or right, backward = up or left)
    focus_prev = {{"alt", "cmd"}, "k"},
    focus_next = {{"alt", "cmd"}, "j"},

    -- move windows around in tiled grid
    swap_left  = {{"alt", "cmd", "shift"}, "left"},
    swap_right = {{"alt", "cmd", "shift"}, "right"},

    -- increase/decrease width
    increase_width = {{ "alt", "cmd" }, "="},
    decrease_width = {{"alt", "cmd"}, "-"},

    -- switch to a new Mission Control space
    switch_space_1 = {{"alt"}, "1"},
    switch_space_2 = {{"alt"}, "2"},
    switch_space_3 = {{"alt"}, "3"},
    switch_space_4 = {{"alt"}, "4"},
    switch_space_5 = {{"alt"}, "5"},

    -- move focused window to a new space and tile
    move_window_1 = {{"alt", "shift"}, "1"},
    move_window_2 = {{"alt", "shift"}, "2"},
    move_window_3 = {{"alt", "shift"}, "3"},
    move_window_4 = {{"alt", "shift"}, "4"},
    move_window_5 = {{"alt", "shift"}, "5"},
})

PaperWM:start()
