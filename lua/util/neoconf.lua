local M = {}

local did_setup = false

function M.setup()
	if did_setup then
		return true
	end

	did_setup = true
	vim.pack.add({
		"https://github.com/folke/neoconf.nvim",
		"https://github.com/neovim/nvim-lspconfig",
	})

	require("neoconf").setup({
		local_settings = ".neoconf.json",
		live_reload = true,
		filetype_jsonc = true,
		import = {
			vscode = false,
			coc = false,
			nlsp = false,
		},
		plugins = {
			lspconfig = { enabled = true },
			jsonls = { enabled = true },
			lua_ls = { enabled_for_neovim_config = true },
		},
	})

	return true
end

function M.get_local(key, defaults, opts)
	M.setup()
	opts = vim.tbl_extend("force", opts or {}, { global = false })
	return require("neoconf").get(key, defaults, opts)
end

return M
