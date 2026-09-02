Config.on_event({ "BufReadPre", "BufNewFile" }, function()
	vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
	local neoconf = require("util.neoconf")
	local lang = require("lang").get()
	local formatters_by_ft = vim.deepcopy(lang.formatters_by_ft)

	for ft, defaults in pairs(lang.formatters_by_ft) do
		formatters_by_ft[ft] = function(bufnr)
			local cfg = neoconf.get_local("tools." .. ft, nil, { buffer = bufnr })
			return cfg and cfg.formatters or defaults
		end
	end

	require("conform").setup({
		notify_on_error = false,

		format_on_save = function(bufnr)
			if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
				return nil
			end

			local ft = vim.bo[bufnr].filetype
			local cfg = neoconf.get_local("tools." .. ft, nil, { buffer = bufnr })
			if cfg and cfg.format_on_save == false then
				return nil
			end

			if (cfg and cfg.format_on_save) or lang.format_on_save[ft] then
				return { timeout_ms = 500 }
			end
			return nil
		end,

		default_format_opts = {
			timeout_ms = 3000,
			async = false,
			quiet = false,
			lsp_format = "fallback",
		},

		formatters_by_ft = formatters_by_ft,
	})

	vim.keymap.set({ "n", "x" }, "<leader>cf", function()
		require("conform").format({ async = true, lsp_format = "fallback" }, function(err)
			if err then
				return
			end
			local mode = vim.api.nvim_get_mode().mode
			if vim.startswith(mode:lower(), "v") then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
			end
		end)
	end, { desc = "Format" })

	return true
end)
