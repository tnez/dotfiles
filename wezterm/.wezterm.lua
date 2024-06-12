local wezterm = require("wezterm")
local config = {}

-- General Appearance
config.enable_tab_bar = false
config.line_height = 1.2
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}
local function maximize_on_startup()
  local _tab, _pane, window = wezterm.mux.spawn_window({})
  window:gui_window():maximize()
end
wezterm.on("gui-startup", maximize_on_startup)

-- Colors
local function get_system_color_mode()
  local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  if handle ~= nil then
    local result = handle and handle:read("*a")
    handle:close()

    if result:match("Dark") then
      return "dark"
    else
      return "light"
    end
  end
end
local system_color_mode = get_system_color_mode()
local color_scheme = {
  dark = "Solarized Dark (Gogh)",
  light = "Solarized Light (Gogh)",
}
config.color_scheme = color_scheme[system_color_mode]
config.set_environment_variables = {
  OS_INTERFACE_STYLE = system_color_mode,
}

-- Fonts
config.font = wezterm.font("Monaspace Neon")
config.font_size = 14.0

-- Keybindings
config.debug_key_events = true -- uncomment this line to see key codes
config.disable_default_key_bindings = true
config.keys = {
  {
    key = "C",
    mods = "CMD|SHIFT",
    action = wezterm.action.CopyTo("Clipboard"),
  },
  {
    key = "V",
    mods = "CMD|SHIFT",
    action = wezterm.action.PasteFrom("Clipboard"),
  },
  {
    key = "q",
    mods = "CMD",
    action = wezterm.action.QuitApplication,
  },
  {
    key = "N",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SendString("\x1b[21;5~"),
  },
  {
    key = "H",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SendString("\x1b[23;5~"),
  },
  {
    key = "L",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SendString("\x1b[24;5~"),
  },
}

return config
