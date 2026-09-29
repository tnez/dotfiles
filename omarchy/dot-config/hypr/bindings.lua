-- Keep Omarchy's packaged defaults; override only the Caps Lock/Ctrl swap.
-- This existing user entrypoint avoids taking ownership of input.lua.
hl.config({
  input = {
    kb_options = 'ctrl:swapcaps',
  },
})
