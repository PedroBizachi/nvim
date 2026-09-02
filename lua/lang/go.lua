return {
	treesitter = { "go", "gomod" },
	lsp = { gopls = require("lsp.gopls") },
	mason = { "gopls", "gofumpt", "goimports", "golangci-lint" },
	formatters_by_ft = { go = { "goimports", "gofumpt" } },
	linteers_by_ft = { go = { "golangci-lint" } },
	format_on_save = { go = true },
	test_runners = { "fredrikaverpil/neotest-golang" },
}
