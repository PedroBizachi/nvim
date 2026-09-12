-- vim.pack.add({ "https://github.com/rebelot/kanagawa.nvim" })
-- vim.pack.add({ "https://github.com/AlexvZyl/nordic.nvim" })
-- vim.pack.add({ "https://github.com/Aejkatappaja/cendre" })
-- vim.pack.add({ "https://github.com/Aejkatappaja/sora" })
vim.pack.add({ "https://github.com/rose-pine/neovim" })
-- vim.pack.add({ "https://github.com/zitrocode/carvion.nvim" })

---@module 'rose-pine'
require("rose-pine").setup({
	styles = {
		transparency = true,
	},
	highlight_groups = {
		NotificationInfo = { bg = "none", fg = "text" },
		NotificationWarning = { bg = "none", fg = "subtle" },
		NotificationError = { bg = "none", fg = "love" },
		MatchParen = { bg = "none" },
		LspFloatWinNormal = { bg = "none" },
		LspInlayHint = { bg = "base", fg = "muted", italic = true },
		BlinkCmpMenu = { bg = "base" },
		BlinkCmpDoc = { bg = "none" },
		BlinkCmpDocSeparator = { bg = "none" },
		Folded = { fg = "muted", bg = "none" }
	}
})
vim.cmd.colorscheme("rose-pine")
