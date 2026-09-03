-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false
--
-- First let's do some key swapping
hl.config({
  input = {
    kb_layout = "us", -- replace with your actual language layout if different
    kb_options = "ctrl:swapcaps", -- comma-separated, no spaces
    repeat_rate = 40,
    repeat_delay = 600,
  }
})

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Use the number-row 0 key for the scratchpad; workspace 10 and group 10
-- are intentionally unused.
hl.unbind("SUPER + code:19")
hl.unbind("SUPER + SHIFT + code:19")
hl.unbind("SUPER + SHIFT + ALT + code:19")
hl.unbind("SUPER + ALT + code:19")
hl.unbind("SUPER + S")
hl.unbind("SUPER + ALT + S")
o.bind("SUPER + 0", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("SUPER + ALT + 0", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
