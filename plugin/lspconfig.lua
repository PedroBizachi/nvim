Config.on_event({ "BufReadPre", "BufNewFile" }, function()
	vim.pack.add({
		"https://github.com/folke/neoconf.nvim",
		"https://github.com/saghen/blink.lib",
		"https://github.com/saghen/blink.cmp",
		"https://github.com/mason-org/mason.nvim",
		"https://github.com/mason-org/mason-lspconfig.nvim",
		"https://github.com/neovim/nvim-lspconfig",
		"https://github.com/b0o/SchemaStore.nvim",
		"https://github.com/artemave/workspace-diagnostics.nvim",
	})
	require("util.neoconf").setup()
	require("workspace-diagnostics").setup()

	-- === LSP Configs ===

	vim.lsp.config("*", {
		capabilities = require("blink-cmp").get_lsp_capabilities(),
		inlay_hints = { enabled = true },
		codelens = { enabled = true },
		folds = { enabled = true },
	})

	-- === Mason ===
	require("mason").setup({
		ui = {
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
			border = "rounded",
		},
	})

	local lang = require("lang").get()
	local servers = lang.lsp

	local ensure_installed = vim.tbl_keys(servers or {})

	require("mason-lspconfig").setup({ ensure_installed = ensure_installed, automatic_enable = false })

	vim.schedule(function()
		if #vim.api.nvim_list_uis() == 0 then
			return
		end

		local registry = require("mason-registry")
		for _, tool in ipairs(lang.mason) do
			local installed_ok, installed = pcall(registry.is_installed, tool)
			if installed_ok and not installed then
				local ok, pkg = pcall(registry.get_package, tool)
				if ok then
					pkg:install()
				end
			end
		end
	end)

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("bizak_lsp_keymaps", { clear = true }),
		callback = function(ev)
			require("lsp.keymaps").on_attach(ev.buf)
		end,
	})

	for server, config in pairs(servers) do
		vim.lsp.config(server, config)
		vim.lsp.enable(server)
	end

	-- === KEYMAPS ===
	local set = vim.keymap.set

	-- mason
	set({ "n" }, "<leader>cM", "<cmd>Mason<cr>", { desc = "Mason" })
end)
