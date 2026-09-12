vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	underline = { severity = { min = vim.diagnostic.severity.WARN } },

	signs = {
		text = {
			[vim.diagnostic.severity.HINT] = Config.icons.diagnostics.Hint,
			[vim.diagnostic.severity.ERROR] = Config.icons.diagnostics.Error,
			[vim.diagnostic.severity.WARN] = Config.icons.diagnostics.Warn,
			[vim.diagnostic.severity.INFO] = Config.icons.diagnostics.Info,
		},
	},

  -- Replaced by tiny-inline-diagnostic
	-- virtual_text = {
	-- 	spacing = 4,
	-- 	source = "if_many",
	-- 	-- prefix = "● ",
	-- 	-- this will set set the prefix to a function that returns the diagnostics icon based on the severity
	-- 	prefix = function(diagnostic)
	-- 		local icons = Config.icons.diagnostics
	--
	-- 		return ({
	-- 			[vim.diagnostic.severity.ERROR] = " " .. icons.Error,
	-- 			[vim.diagnostic.severity.WARN] = " " .. icons.Warn,
	-- 			[vim.diagnostic.severity.INFO] = " " .. icons.Info,
	-- 			[vim.diagnostic.severity.HINT] = " " .. icons.Hint,
	-- 		})[diagnostic.severity] or "● "
	-- 	end,
	-- 	suffix = " ",
	-- },

	-- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
	jump = {
		on_jump = function(_, bufnr)
			vim.diagnostic.open_float({
				bufnr = bufnr,
				scope = "cursor",
				focus = false,
				source = true,
			})
		end,
	},
})
