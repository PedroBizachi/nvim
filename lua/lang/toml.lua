---@type vim.lsp.Config
return {
	treesitter = { "toml" },
	lsp = { taplo = {} },
	mason = { "taplo" },
	formatters_by_ft = { toml = { "taplo" } },
	format_on_save = { toml = true },
}
