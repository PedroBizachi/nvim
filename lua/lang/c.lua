return {
	treesitter = { "c", "cpp", "cmake", "make" },
	lsp = {
		clangd = {},
	},
	mason = { "clang-format", "clang-tidy" },
	formatters_by_ft = {
		c = { "clang_format" },
		cpp = { "clang_format" },
		objc = { "clang_format" },
		objcpp = { "clang_format" },
	},
	format_on_save = {
		c = true,
		cpp = true,
		objc = true,
		objcpp = true,
	},
	linters_by_ft = {
		c = { "clangtidy" },
		cpp = { "clangtidy" },
		objc = { "clangtidy" },
		objcpp = { "clangtidy" },
	},
}
