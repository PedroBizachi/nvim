local o = vim.o
local g = vim.g
local opt = vim.opt

-- === OPTIONS ===

g.mapleader = " "
g.maplocalleader = "\\"

-- Numbers
o.number = true
o.rnu = true
o.numberwidth = 4
o.ruler = false
o.cursorline = true
o.cursorlineopt = "number"

-- Indenting
o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2

-- Completion
opt.completeopt = "menuone,noselect,fuzzy,nosort"
opt.shortmess:append("c")
g.ai_cmp = false
o.wildmenu = true
o.wildmode = "longest:full,full"

-- Folding
opt.foldlevel = 99
opt.foldlevelstart = 1
opt.foldminlines = 10
opt.foldtext = ""

-- Formatting
-- opt.formatexpr = "v:lua.LazyVim.format.formatexpr()"
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
g.cursorcolumn_width = 120

-- QoL
o.autochdir = false
o.cmdheight = 0
o.autoread = true
o.autowrite = false
o.signcolumn = "yes"
o.laststatus = 3
o.splitkeep = "screen"
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.synmaxcol = 300
o.splitbelow = true
o.splitright = true
o.timeoutlen = 400
o.undofile = true
o.backup = false
o.writebackup = false
o.swapfile = false
o.updatetime = 200
o.confirm = true
o.wrap = false
o.breakindent = true
opt.scrolloff = 10
opt.whichwrap:append("<>[]hl")
o.list = true

-- Style
o.encoding = "utf-8"
opt.termguicolors = true
vim.env.COLORTERM = "truecolor"
g.have_nerd_font = true

-- Performance
o.redrawtime = 10000
o.maxmempattern = 20000
g.loaded_gzip = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_netrwSettings = 1
g.loaded_netrwFileHandlers = 1
g.loaded_tutor_mode_plugin = 1
g.loaded_2html_plugin = 1
g.loaded_matchit = 1
g.loaded_matchparen = 1
o.shada = "'50,<20,s5,:200,/50,@50,h" -- Limit ShaDa file (for startup)
