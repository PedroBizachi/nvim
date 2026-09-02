local M = {}

-- stylua: ignore start
-- === LANGUAGE CONFIGURATION ===
-- Language-specific editor support lives in `lua/lang/`.
-- Each file returns a plain table describing what that language needs:
--   treesitter       = parsers to install/start
--   lsp              = LSP server configs consumed by `plugin/lspconfig.lua`
--   mason            = non-LSP tools to install with Mason, like formatters/linters
--   formatters_by_ft = Conform formatters consumed by `plugin/conform.lua`
--   format_on_save   = filetypes that should be formatted on save
--   linters_by_ft    = nvim-lint linters consumed by `plugin/lint.lua`
--   test_runners     = Neotest adapter plugins consumed by `plugin/neotest.lua`
--
-- To add a new language:
--   1. Create `lua/lang/<name>.lua` and return the table described above.
--   2. Add `"lang.<name>"` to the `modules` list in `lua/lang/init.lua`.
--   3. Put custom LSP settings in `lua/lsp/<server>.lua` if they are large.
--   4. Keep plugin files as consumers only; language choices belong in `lua/lang/`.
--
-- Example:
--   return {
--     treesitter = { "go", "gomod" },
--     lsp = { gopls = {} },
--     mason = { "gofumpt", "goimports" },
--     formatters_by_ft = { go = { "goimports", "gofumpt" } },
--     format_on_save = { go = true },
--     test_runners = { "fredrikaverpil/neotest-golang" },
--   }

local modules = {
	"lang.lua",
	"lang.python",
	"lang.markdown",
	"lang.json",
	"lang.shell",
	"lang.web",
	"lang.git",
	"lang.toml",
	"lang.go",
}

local extend_unique = function(dst, src)
	for _, item in ipairs(src or {}) do
		if not vim.tbl_contains(dst, item) then
			table.insert(dst, item)
		end
	end
end

local merge_map = function(dst, src)
	for key, value in pairs(src or {}) do
		dst[key] = value
	end
end

M.get = function()
	local result = {
		treesitter = {},
		lsp = {},
		mason = {},
		formatters_by_ft = {},
		format_on_save = {},
		linters_by_ft = {},
		test_runners = {},
	}

	for _, mod in ipairs(modules) do
		local ok, lang = pcall(require, mod)
		if ok then
			extend_unique(result.treesitter, lang.treesitter)
			extend_unique(result.mason, lang.mason)
			merge_map(result.lsp, lang.lsp)
			merge_map(result.formatters_by_ft, lang.formatters_by_ft)
			merge_map(result.format_on_save, lang.format_on_save)
			merge_map(result.linters_by_ft, lang.linters_by_ft)
			extend_unique(result.test_runners, lang.test_runners)
		end
	end

	return result
end

return M
