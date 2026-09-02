---@type vim.lsp.Config
return {
	capabilities = require("blink-cmp").get_lsp_capabilities(),
	settings = {
		gopls = {
			analyses = { unusedparams = true },
			staticcheck = true,
			gofumpt = true, -- Tells gopls to use gofumpt formatting rules
			usePlaceholders = true,
		},
	},
}
