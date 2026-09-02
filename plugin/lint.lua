Config.on_event({ "BufReadPre", "BufNewFile" }, function()
	vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })

	local neoconf = require("util.neoconf")
	local lint = require("lint")
	lint.linters_by_ft = require("lang").get().linters_by_ft

	local configured_linters = function(bufnr)
		local ft = vim.bo[bufnr].filetype
		local cfg = neoconf.get_local("tools." .. ft, nil, { buffer = bufnr })
		return cfg and cfg.linters or lint.linters_by_ft[ft] or {}
	end

	local available_linters = function(bufnr)
		local names = configured_linters(bufnr)
		local available = {}
		for _, name in ipairs(names) do
			local linter = lint.linters[name]
			local cmd = type(linter) == "table" and linter.cmd or nil
			if cmd == nil or vim.fn.executable(cmd) == 1 then
				table.insert(available, name)
			end
		end
		return available
	end

	-- Create autocommand which carries out the actual linting
	-- on the specified events.
	local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
	vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
		group = lint_augroup,
		callback = function()
			-- Only run the linter in buffers that you can modify in order to
			-- avoid superfluous noise, notably within the handy LSP pop-ups that
			-- describe the hovered symbol using Markdown.
			if vim.bo.modifiable then
				local linters = available_linters(0)
				if #linters > 0 then
					lint.try_lint(linters)
				end
			end
		end,
	})
end)
