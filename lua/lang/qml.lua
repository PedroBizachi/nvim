return {
	treesitter = { "qmldir", "qmljs" },
	lsp = {
		qmlls = {
			-- stylua: ignore
			cmd = {
				"/usr/lib/qt6/bin/qmlls",
				"-I", "/usr/lib/qt6/qml",
				"-I", vim.fn.expand("~/.local/share/omarchy/qml-imports"),
				"-d", "/usr/share/doc/qt6",
			},
		},
	},
	format_on_save = { qml = true, qmljs = true },
}
