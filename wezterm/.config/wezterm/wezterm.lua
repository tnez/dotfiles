-- set XDG_CONFIG_HOME
os.execute("export XDG_CONFIG_HOME=$HOME/.config")

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- General Appearance
config.line_height = 1.2
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Colors
local function get_system_color_mode()
  if wezterm.gui then
    local appearance = wezterm.gui.get_appearance()

    if appearance:find("Dark") then
      return "dark"
    end
  end

  return "light"
end

local function get_color_scheme()
  local available_schemes = {
    dark = "Tokyo Night Storm",
    light = "Tokyo Night Day",
  }

  return available_schemes[get_system_color_mode()]
end

config.color_scheme = get_color_scheme()

-- Fonts
config.font = wezterm.font("Monaspace Neon")
config.font_size = 14.0
config.font_rules = {
  {
    italic = true,
    intensity = "Bold",
    font = wezterm.font("Monaspace Radon", { weight = "Black" }),
  },
  {
    intensity = "Bold",
    font = wezterm.font("Monaspace Neon", { weight = "Bold" }),
  },
  {
    italic = true,
    font = wezterm.font("Monaspace Radon", { italic = true, weight = "Thin" }),
  },
}

-- Keybindings
config.debug_key_events = true -- uncomment this line to see key codes
config.disable_default_key_bindings = true
config.keys = {
  -- Fonts
  {
    key = "+",
    mods = "CMD",
    action = wezterm.action.IncreaseFontSize,
  },
  ---- Decrease font size
  {
    key = "-",
    mods = "CMD",
    action = wezterm.action.DecreaseFontSize,
  },
  ---- Reset font size to default
  {
    key = "0",
    mods = "CMD",
    action = wezterm.action.ResetFontSize,
  },
}

-- Disable tab bar
config.enable_tab_bar = false

return config
