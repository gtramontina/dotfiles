-- Custom ----------------------------------------------------------------------

local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("Berkeley Mono Variable")
config.font_size = 13.0
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20

config.leader = { mods = "CTRL", key = "b", timeout_milliseconds = 2000 }
config.keys = {
  { mods = "CTRL|CMD", key = "f", action = wezterm.action.ToggleFullScreen },
  { mods = "LEADER", key = "\\", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { mods = "LEADER", key = "-", action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },
  { mods = "ALT", key = "LeftArrow", action = wezterm.action.ActivatePaneDirection "Left" },
  { mods = "ALT", key = "RightArrow", action = wezterm.action.ActivatePaneDirection "Right" },
  { mods = "ALT", key = "UpArrow", action = wezterm.action.ActivatePaneDirection "Up" },
  { mods = "ALT", key = "DownArrow", action = wezterm.action.ActivatePaneDirection "Down" },
  { mods = "LEADER", key = "z", action = wezterm.action.TogglePaneZoomState },
}

config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

wezterm.plugin.require("https://github.com/nekowinston/wezterm-bar").apply_to_config(config, {
  position = "top",
  max_width = 32,
  dividers = "slant_right",
  indicator = {
    leader = {
      enabled = true,
      off = wezterm.nerdfonts.fa_toggle_off,
      on = wezterm.nerdfonts.fa_toggle_on,
    },
    mode = {
      enabled = true,
      names = {
        resize_mode = "RESIZE",
        copy_mode = "VISUAL",
        search_mode = " " .. wezterm.nerdfonts.md_magnify .. " ",
      },
    },
  },
  tabs = {
    numerals = "arabic", -- or "roman"
    pane_count = "superscript", -- or "subscript", false
    brackets = {
      active = { "", ":" },
      inactive = { "", ":" },
    },
  },
  clock = { enabled = false },
})

config.harfbuzz_features = {
  "liga", "cv02", "cv19", "cv25", "cv26",
  "cv28", "cv30", "cv32", "ss02", "ss03",
  "ss05", "ss07", "ss09", "zero",
}

function battery_icon(battery_info)
  local charge = battery_info.state_of_charge
  local state = battery_info.state

  if state == "Charging"
  then
    if charge < 0.1
    then
      return "md_battery_charging_10"
    elseif charge < 0.25
    then
      return "md_battery_charging_20"
    elseif charge < 0.5
    then
      return "md_battery_charging_50"
    elseif charge < 0.75
    then
      return "md_battery_charging_80"
    else
      return "md_battery_charging_100"
    end
  end

  if charge < 0.1
  then
    return "fa_battery_empty"
  elseif charge < 0.25
  then
    return "fa_battery_quarter"
  elseif charge < 0.5
  then
    return "fa_battery_half"
  elseif charge < 0.75
  then
    return "fa_battery_three_quarters"
  else
    return "fa_battery_full"
  end
end

function battery_color(battery_info)
    local charge = battery_info.state_of_charge
    local hue = tostring(charge * 120)
    return "hsl(" .. hue .. ",100%,50%)"
end

wezterm.on("update-right-status", function(window, pane)
  local date = wezterm.strftime "%a %b %-d %H:%M:%S"

  local battery_info
  local batt = ""
  for _, current in ipairs(wezterm.battery_info()) do
    battery_info = current
    local charge = battery_info.state_of_charge
    batt = string.format("%.0f%%", charge * 100)
  end

  window:set_right_status(wezterm.format {
    { Foreground = { Color = "#CACACA" } },
    { Text = utf8.char(0xe0be) },
    { Background = { Color = "#CACACA" } },
    { Foreground = { Color = "#000000" } },
    { Text = " " .. wezterm.nerdfonts.fa_clock_o .. " " },
    { Text = date .. " " },
    { Foreground = { Color = "#333333" } },
    { Text = utf8.char(0xe0be) },
    { Background = { Color = "#333333" } },
    { Foreground = { Color = "#FFFFFF" } },
    { Foreground = { Color = battery_color(battery_info) } },
    { Text = " " .. wezterm.nerdfonts[battery_icon(battery_info)] .. " " },
    { Foreground = { Color = "#FFFFFF" } },
    { Text = batt .. " " },
  })
end)

wezterm.on("window-config-reloaded", function(window, pane)
  local name = "Catppuccin Latte"
  -- local name = "Everforest Light (Gogh)"
  local appearance = window:get_appearance()
  if appearance:find("Dark") then
    name = "Catppuccin Mocha"
    -- name = "Everforest Dark (Gogh)"
  end

  local overrides = window:get_config_overrides() or {}
  if overrides.color_scheme ~= name then
    overrides.color_scheme = name;
    window:set_config_overrides(overrides)
  end
end)

return config

