local ctx_is_loaded, ctx = pcall(require, "user.snippets._context")
if not ctx_is_loaded then
	return
end

ctx.add("typescript", {
	ctx.snippet({
		trig = "desc",
		name = "Describe Block",
	}, {
		ctx.text("describe('"),
		ctx.insert(1),
		ctx.text({ "', () => {", "  " }),
		ctx.insert(0),
		ctx.text({ "", "})" }),
	}),
	ctx.snippet({
		trig = "bef",
		name = "Before All",
	}, {
		ctx.text({ "beforeAll(() => {" }, { "  " }),
		ctx.insert(0),
		ctx.text({ "", "})" }),
	}),
	ctx.snippet({
		trig = "befa",
		name = "Async Before All",
	}, {
		ctx.text({ "beforeAll(async () => {" }, { "  " }),
		ctx.insert(0),
		ctx.text({ "", "})" }),
	}),
	ctx.snippet({
		trig = "itt",
		name = "Todo Spec",
	}, {
		ctx.text("it.todo('"),
		ctx.insert(1),
		ctx.text("')"),
	}),
	ctx.snippet({
		trig = "tb",
		name = "Test Block",
	}, {
		ctx.text({ "() => {", "  // Given...", "  " }),
		ctx.insert(0),
		ctx.text({ "", "  // When...", "" }),
		ctx.text({ "", "  // Then...", "", "}" }),
	}),
	ctx.snippet({
		trig = "tba",
		name = "Async Test Block",
	}, {
		ctx.text({ "async () => {", "  // Given...", "  " }),
		ctx.insert(0),
		ctx.text({ "", "  // When...", "" }),
		ctx.text({ "", "  // Then...", "", "}" }),
	}),
})
