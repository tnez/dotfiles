local luasnip_loaded, ls = pcall(require, "luasnip")
if not luasnip_loaded then
	return
end

local file_paths = {
	"user.snippets.all",
	"user.snippets.typescript",
}

for _, path in ipairs(file_paths) do
	local snippet_file_loaded, _ = pcall(require, path)
	if not snippet_file_loaded then
		error("Could not load" + path)
	end
end
