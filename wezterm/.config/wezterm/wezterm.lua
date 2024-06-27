local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- General Appearance
config.enable_tab_bar = true
config.line_height = 1.2
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- On Startup
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

-- Navigation helpers for between splits with hjkl that work in both vim and
-- wezterm
local function is_vim(pane)
  return pane:get_user_vars().IS_NVIM == "true"
end
local direction_keys = {
  h = "Left",
  j = "Down",
  k = "Up",
  l = "Right",
}
local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == "resize" and "CMD" or "CTRL",
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = {
            key = key,
            mods = resize_or_move == "resize" and "META" or "CTRL",
          },
        }, pane)
      else
        if resize_or_move == "resize" then
          win:perform_action(
            { AdjustPaneSize = { direction_keys[key], 3 } },
            pane
          )
        else
          win:perform_action(
            { ActivatePaneDirection = direction_keys[key] },
            pane
          )
        end
      end
    end),
  }
end

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
  -- Decrease font size
  {
    key = "-",
    mods = "CMD",
    action = wezterm.action.DecreaseFontSize,
  },
  -- Reset font size to default
  {
    key = "0",
    mods = "CMD",
    action = wezterm.action.ResetFontSize,
  },
  -- Copy / Paste
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
  -- Quit
  {
    key = "q",
    mods = "CMD",
    action = wezterm.action.QuitApplication,
  },
  -- Tab Navigation
  {
    key = "N",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SpawnTab("DefaultDomain"),
  },
  {
    key = "H",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = "L",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = "i",
    mods = "CTRL",
    action = wezterm.action.PromptInputLine({
      description = "Enter new name for the tab",
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
  -- Panes
  {
    key = "/",
    mods = "CTRL",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "-",
    mods = "CTRL",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "Enter",
    mods = "CTRL",
    action = wezterm.action.RotatePanes("Clockwise"),
  },
  -- move between split panes
  split_nav("move", "h"),
  split_nav("move", "j"),
  split_nav("move", "k"),
  split_nav("move", "l"),
  -- resize panes
  split_nav("resize", "h"),
  split_nav("resize", "j"),
  split_nav("resize", "k"),
  split_nav("resize", "l"),

  -- Workspaces
  {
    key = " ",
    mods = "CTRL",
    action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES" }),
  },
  {
    key = "I",
    mods = "CTRL|SHIFT",
    action = wezterm.action.PromptInputLine({
      description = "Enter new name for the workspace",
      action = wezterm.action_callback(function(window, _, line)
        if line then
          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
        end
      end),
    }),
  },
}

-- Tab Bar Stuff
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
-- config.hide_tab_bar_if_only_one_tab = true

local tab_colors = {
  dark = {
    active_tab = {
      bg_color = "#282a36",
      fg_color = "#f8f8f2",
    },
    inactive_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#6272a4",
    },
    new_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#6272a4",
    },
    new_tab_hover = {
      bg_color = "#44475a",
      fg_color = "#f8f8f2",
    },
  },
  light = {
    background = "#e0e0e0",
    active_tab = {
      bg_color = "#ffffff",
      fg_color = "#000000",
    },
    inactive_tab = {
      bg_color = "#e0e0e0",
      fg_color = "#555555",
    },
    new_tab = {
      bg_color = "#e0e0e0",
      fg_color = "#555555",
    },
    new_tab_hover = {
      bg_color = "#cccccc",
      fg_color = "#000000",
    },
  },
}

config.colors = {}
config.colors.tab_bar = tab_colors[system_color_mode]

-- Pane Styling
config.inactive_pane_hsb = {
  saturation = 0.5,
  brightness = 0.5,
}

return config
