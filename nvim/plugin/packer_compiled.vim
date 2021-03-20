" Automatically generated packer.nvim plugin loader code

if !has('nvim-0.5')
  echohl WarningMsg
  echom "Invalid Neovim version for packer.nvim!"
  echohl None
  finish
endif

packadd packer.nvim

try

lua << END
local package_path_str = "/home/tnez/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?.lua;/home/tnez/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?/init.lua;/home/tnez/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?.lua;/home/tnez/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/tnez/.cache/nvim/packer_hererocks/2.0.5/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    print('Error running ' .. component .. ' for ' .. name)
    error(result)
  end
  return result
end

_G.packer_plugins = {
  ["editorconfig-vim"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/editorconfig-vim"
  },
  ["goyo.vim"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/goyo.vim"
  },
  ["lsp_extensions.nvim"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/lsp_extensions.nvim"
  },
  ["lspsaga.nvim"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/lspsaga.nvim"
  },
  neoformat = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/neoformat"
  },
  nerdcommenter = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/nerdcommenter"
  },
  ["nlua.nvim"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/nlua.nvim"
  },
  ["nvim-autopairs"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/nvim-autopairs"
  },
  ["nvim-compe"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/nvim-compe"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["vim-bufkill"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/vim-bufkill"
  },
  ["vim-floaterm"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/vim-floaterm"
  },
  ["vim-mergetool"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/vim-mergetool"
  },
  ["vim-rooter"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/vim-rooter"
  },
  ["vim-snippets"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/vim-snippets"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/vim-surround"
  },
  ["vim-xo"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/vim-xo"
  },
  ["wal.vim"] = {
    loaded = true,
    path = "/home/tnez/.local/share/nvim/site/pack/packer/start/wal.vim"
  }
}

END

catch
  echohl ErrorMsg
  echom "Error in packer_compiled: " .. v:exception
  echom "Please check your config for correctness"
  echohl None
endtry
