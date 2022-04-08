local ctx_is_loaded, ctx = pcall(require, "user.snippets._context")
if not ctx_is_loaded then
	return
end

ctx.add("all", {
	ctx.snippet({
		trig = "hello",
		name = "HelloWorld",
		dscr = "A simple text snippet to test adding custom snippets",
	}, {
		ctx.text({ "Hello " }),
		ctx.insert(1, "<your-name>"),
		ctx.text({ "!" }),
	}),
})
