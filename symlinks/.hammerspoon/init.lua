hs.logger.defaultLogLevel="info"
hs.window.animationDuration = 0

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
Install=spoon.SpoonInstall

hyper = { "cmd", "alt", "ctrl" }
shift_hyper = { "cmd", "alt", "ctrl", "shift" }

-- http://www.hammerspoon.org/Spoons/ReloadConfiguration.html
Install:andUse("ReloadConfiguration", {
  start = true,
  hotkeys = {
    reloadConfiguration = { hyper, "r" }
  },
})

-- http://www.hammerspoon.org/Spoons/Caffeine.html
Install:andUse("Caffeine", {
  start = true
})

-- http://www.hammerspoon.org/Spoons/WiFiTransitions.html
Install:andUse("WiFiTransitions", {
  start = true,
  config = {
    actions = {
      {
        fn = function(_, _, prev_ssid, new_ssid)
          local changed = prev_ssid ~= nil
          local title = (changed and "WiFi SSID Changed" or "WiFi Connected")
          local description = (changed and string.format("From: %s\nTo: %s", prev_ssid, new_ssid) or string.format("SSID: %s", new_ssid))
          hs.notify.show(title, description, "")
        end
      }
    }
  },
})

-- http://www.hammerspoon.org/Spoons/WindowHalfsAndThirds.html
Install:andUse("WindowHalfsAndThirds", {
  config = {
    use_frame_correctness = true
  },
  hotkeys = {
    left_half   = { hyper, "Left" },
    right_half  = { hyper, "Right" },
    top_half    = { hyper, "Up" },
    bottom_half = { hyper, "Down" },
    third_left  = { shift_hyper, "Left" },
    third_right = { shift_hyper, "Right" },
    third_up    = { shift_hyper, "Up" },
    third_down  = { shift_hyper, "Down" },
    top_left    = { hyper, "1" },
    top_right   = { hyper, "2" },
    bottom_left = { hyper, "3" },
    bottom_right= { hyper, "4" },
    max_toggle  = { hyper, "f" },
    max         = { hyper, "m" },
 },
})

-- http://www.hammerspoon.org/Spoons/WindowGrid.html
Install:andUse("WindowGrid", {
  start = true,
  config = {
    gridGeometries = { { "6x4" } }
  },
  hotkeys = {
    show_grid = { hyper, "g" }
  },
})

-- http://www.hammerspoon.org/Spoons/TextClipboardHistory.html
Install:andUse("TextClipboardHistory", {
  start = true,
  config = {
    show_in_menubar = false,
  },
  hotkeys = {
    toggle_clipboard = { { "cmd", "shift" }, "v" }
  },
})

hs.notify.show("Hammerspoon", "Configuration loaded", '')

-- timer
hs.hotkey.bind(hyper, "T", function()
  local success, obj, descriptor = hs.osascript._osascript("set t to (time string of (current date))", "AppleScript")
  hs.alert.show(obj)
end)
