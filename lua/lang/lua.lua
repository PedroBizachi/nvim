return {
	treesitter = { "lua", "luadoc", "luap", "vim", "vimdoc", "query" },
	lsp = {
		lua_ls = require("lsp.lua_ls"),
	},
	mason = { "stylua", "copilot-language-server" },
	formatters_by_ft = {
		lua = { "stylua" },
	},
	format_on_save = {
		lua = true,
	},
	test_runners = {
		"nvim-neotest/neotest-plenary",
	},
}
