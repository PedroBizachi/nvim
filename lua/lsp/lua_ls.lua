-- stylua: ignore
return {
	on_init = function(client)
		client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
		end
	end,
	---@diagnostic disable-next-line: undefined-doc-name
	---@type lspconfig.settings.lua_ls
	settings = {
		Lua = {
			codeLens = {
				enable = true,
			},
			completion = {
				autoRequire = true,
				callSnippet = "Replace",
				displayContext = 5,
			},
			diagnostics = {
				globals = { "vim", "Config", "MiniIcons", "Snacks", "require", "MiniFiles" },
			},
			doc = {
				privateName = { "^_" },
				regengine = "lua",
			},
			hint = {
				arrayIndex = "Disable",
				enable = true,
				paramType = true,
				paramName = "Disable",
				semicolon = "Disable",
				setType = true,
			},
			runtime = {
				version = "LuaJIT",
			},
			workspace = {
				checkThirdParty = false,
			},
		},
	},
}
