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
config.tab_bar_at_bottom = true

local theme_colors = {
  dark = {
    background = "#002b36",
    background_highlight = "#073642",
    comments = "#586e75",
    body_text = "#839496",
    emphasized_text = "#93a1a1",
  },
  light = {
    background = "#fdf6e3",
    background_highlight = "#eee8d5",
    comments = "#93a1a1",
    body_text = "#657b83",
    emphasized_text = "#586e75",
  },
}

local function tab_colors(variant)
  local c = theme_colors[variant]

  return {
    background = c.background_highlight,
    active_tab = {
      bg_color = c.background,
      fg_color = c.emphasized_text,
    },
    inactive_tab = {
      bg_color = c.background_highlight,
      fg_color = c.comments,
    },
    inactive_tab_hover = {
      bg_color = c.background,
      fg_color = c.emphasized_text,
    },
    new_tab = {
      bg_color = c.background_highlight,
      fg_color = c.comments,
    },
    new_tab_hover = {
      bg_color = c.background,
      fg_color = c.emphasized_text,
    },
  }
end

config.colors = {}
config.colors.tab_bar = tab_colors(system_color_mode)

wezterm.on("update-right-status", function(window, pane)
  -- Make it italic and underlined
  window:set_right_status(wezterm.format({
    { Attribute = { Underline = "Single" } },
    { Attribute = { Italic = true } },
    { Text = "TODO: What should go here? Session / Worktree / Etc... " },
  }))
end)

-- Pane Styling
config.inactive_pane_hsb = {
  saturation = 0.5,
  brightness = 0.5,
}

return config
