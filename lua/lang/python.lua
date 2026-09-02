vim.g.python_indent = {
	open_paren = "shiftwidth()",
	nested_paren = "shiftwidth()",
	continue = "shiftwidth() * 2",
	closed_paren_align_last_line = false,
}

---@type vim.lsp.Config
return {
	treesitter = { "python", "ninja", "rst" },
	lsp = {
		basedpyright = {
			settings = {
				basedpyright = {
					analysis = {
						typeCheckingMode = "strict",
						strictListInference = true,
					},
				},
			},
		},
	},
	mason = { "basedpyright", "ruff", "black", "mypy", "copilot-language-server" },
	formatters_by_ft = {
		python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
	},
	linters_by_ft = { "ruff" },
	format_on_save = {
		python = true,
	},
	test_runners = {
		{
			plugin = "nvim-neotest/neotest-python",
			opts = {
				dap = { justMyCode = false },
			},
		},
	},
}
