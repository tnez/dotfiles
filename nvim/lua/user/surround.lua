local required_ok, surround = pcall(require, "surround")
if not required_ok then
	vim.notify("surround package not found!")
	return
end

surround.setup({
	mappings_style = "sandwich",
	quotes = { "'", '"', "`" },
})

local set_n_keymap = function(from, to)
	vim.api.nvim_set_keymap("n", from, to, { silent = true })
end

set_n_keymap("t'", "stq")
set_n_keymap("tb", "stb")
