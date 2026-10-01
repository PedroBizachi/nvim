local palette = {
	base = "#191724",
	overlay = "#26233a",
	muted = "#6e6a86",
	subtle = "#908caa",
	text = "#e0def4",
}

-- NOTE: Bootstrap for initial load performance
for group, highlight in pairs({
	Normal = { fg = palette.text, bg = "NONE" },
	NormalFloat = { fg = palette.text, bg = "NONE" },
	NormalNC = { fg = palette.text, bg = "NONE" },
	EndOfBuffer = { fg = palette.muted, bg = "NONE" },
	SignColumn = { fg = palette.text, bg = "NONE" },
	LineNr = { fg = palette.muted, bg = "NONE" },
	CursorLine = { bg = palette.overlay },
	StatusLine = { fg = palette.subtle, bg = "NONE" },
	StatusLineNC = { fg = palette.muted, bg = "NONE" },
	WinSeparator = { fg = palette.muted, bg = "NONE" },
	FloatBorder = { fg = palette.muted, bg = "NONE" },
	Pmenu = { fg = palette.subtle, bg = "NONE" },
}) do
	vim.api.nvim_set_hl(0, group, highlight)
end

-- NOTE: Colorscheme configuration
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("bizak_rose_pine", { clear = true }),
	once = true,
	callback = function()
		vim.schedule(function()
			vim.pack.add({ "https://github.com/rose-pine/neovim" })

			---@module 'rose-pine'
			require("rose-pine").setup({
				variant = "main",
				enable = {
					legacy_highlights = false,
					migrations = false,
					terminal = false,
				},
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
					BlinkCmpMenuSelection = { bg = "highlight_med", fg = "none" },
					Folded = { fg = "muted", bg = "none" },
				},
			})
			vim.cmd.colorscheme("rose-pine")
		end)
	end,
})
