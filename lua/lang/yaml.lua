---@type vim.lsp.Config
return {
	treesitter = { "yaml" },
	lsp = { yamlls = {} },
	mason = { "yaml-language-server" },
	formatters_by_ft = { yaml = { "yaml-language-server" } },
	format_on_save = { yaml = true },
}
