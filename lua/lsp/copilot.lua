---@type vim.lsp.Config
return {
	capabilities = {
		textDocument = {
			inlineCompletion = {
				dynamicRegistration = true,
			},
		},
	},
	settings = {
		copilot = {
			debounce = 500,
			disabledFiletypes = { "markdown", "plaintext" },
		},
	},
}
