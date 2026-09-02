return {
	treesitter = {
		"css",
		"diff",
		"html",
		"javascript",
		"jsdoc",
		"printf",
		"regex",
		"toml",
		"tsx",
		"typescript",
		"xml",
		"yaml",
		"http",
		"graphql",
	},
	lsp = {
		cssls = require("lsp.cssls"),
	},
	mason = { "copilot-language-server", "cssls" },
	test_runners = {
		"marilari88/neotest-vitest",
		"nvim-neotest/neotest-jest",
	},
}
