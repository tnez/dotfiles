local luasnip_loaded, ls = pcall(require, "luasnip")
if not luasnip_loaded then
	error("luasnip could not be loaded")
	return
end

local ctx = {}

ctx.add = ls.add_snippets
ctx.snippet = ls.snippet
ctx.insert = ls.insert_node
ctx.text = ls.text_node

return ctx
