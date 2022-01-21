vim.g.tokyonight_style = "day"

local status_ok, _ = pcall(vim.cmd, "colorscheme tokyonight")
if not status_ok then
	vim.notify("colorscheme `tokyonight` not found!")
	return
end
