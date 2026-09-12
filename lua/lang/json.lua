return {
	treesitter = { "json" },
	lsp = {
		jsonls = {
			settings = {
			---@module 'lspconfig'
			---@type _.lspconfig.settings.jsonls.Json
				json = {
					schemas = require('schemastore').json.schemas(),
					validate = { enable = true }
				}
			}
		},
	},
}
