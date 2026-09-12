local set = vim.keymap.set

-- stylua: ignore start
-- === Navigation ===

-- Better up/down
set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'",      { desc = "Down", expr = true, silent = true })
set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'",      { desc = "Up",   expr = true, silent = true })
set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'",   { desc = "Up",   expr = true, silent = true })

-- Move down without moving the cursor
set("n", "<C-d>", "<C-d>zzzz", { desc = "Scroll Down" })
set("n", "<C-u>", "<C-u>zzzz", { desc = "Scroll Up" })

-- windows
set("n", "<leader>-", "<C-W>s",  { desc = "Split Window Below", remap = true })
set("n", "<leader>|", "<C-W>v",  { desc = "Split Window Right", remap = true })
set("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- Move to window using the <ctrl> hjkl keys
set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Leader
set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- buffers
set("n", "<S-h>",      "<cmd>bprevious<cr>",                        { desc = "Prev Buffer" })
set("n", "<S-l>",      "<cmd>bnext<cr>",                            { desc = "Next Buffer" })
set("n", "[b",         "<cmd>bprevious<cr>",                        { desc = "Prev Buffer" })
set("n", "]b",         "<cmd>bnext<cr>",                            { desc = "Next Buffer" })
set("n", "<leader>bd", function() Snacks.bufdelete() end,           { desc = "Delete Buffer" })
set("n", "<leader>bo", function() Snacks.bufdelete.other() end,     { desc = "Delete Other Buffers" })
set("n", "<leader>bi", function() Snacks.bufdelete.invisible() end, { desc = "Delete Invisible Buffers" })
set("n", "<leader>bD", "<cmd>:bd<cr>",                              { desc = "Delete Buffer and Window" })

-- File Explorer
set("n", "<leader>e", function() MiniFiles.open() end,                                    { silent = true, desc = "File explorer" })
set("n", "<leader>E", function() MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end, { silent = true, desc = "File explorer in current directory" })

-- === LSP ===
set("n", "<leader>xx", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- === QoL ===

-- lazygit
if vim.fn.executable("lazygit") == 1 then
	set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit (Root Dir)" })
	set("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
end

-- lua
set({ "n", "x" }, "<localleader>r", function()
	Snacks.debug.run()
end, { desc = "Run Lua" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
set(
	"n",
	"<leader>uR",
	"<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
	{ desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- Man files
set("n", "<leader>cK", "<cmd>norm! K<cr>", { desc = "Man file" })

-- highlights under cursor
set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
set("n", "<leader>uI", function()
	vim.treesitter.inspect_tree()
	vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })

-- Clear highlights on search when pressing <Esc> in normal mode
set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlight" })

-- save file
set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- copy file
set({ "i", "x", "n", "s" }, "<C-c>", "<cmd>%y<cr><esc>", { desc = "Copy File" })

-- Find/replace
set("n", "?", ":%s/", { desc = "Substitute" })
set("x", "?", function()
  vim.cmd('normal! "vy') -- Yank actual selection
  local selection = vim.fn.getreg("v")
  -- Make a custom command with the yanked text
  local keys = vim.api.nvim_replace_termcodes(":%s/" .. selection .. "/", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false) -- Send the command to Neovim
end, { desc = "Substitute visual selection file-wide" })

-- Select entire file
set("v", "V", "<esc>ggVG", { silent = true, desc = "Select entire file" })

-- Quit with ease
set("n", "<leader>q", ":q<cr>", { silent = true })

-- Redo
set("n", "U", "<c-r>", { silent = true })

-- better indenting
set("x", "<", "<gv", { desc = "Indent Left" })
set("x", ">", ">gv", { desc = "Indent Right" })

-- Restart Neovim
set("n", "<leader>ur", "<cmd>Restart<cr>", { desc = "Restart Neovim" })

-- TODO: Preserve yanked text from Theprimeagen

-- Yank line and paste above/below
set("n", "<M-J>", "yyp",                 { desc = "Duplicate line below" })
set("n", "<M-K>", "yyP",                 { desc = "Duplicate line above" })
set("v", "<M-J>", [[:co '><CR>gv=gv]],   { desc = "Duplicate selection below" })
set("v", "<M-K>", [[:co '<-1<CR>gv=gv]], { desc = "Duplicate selection above" })

-- Move Lines
set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==",                   { desc = "Move Down" })
set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==",             { desc = "Move Up" })
set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi",                                   { desc = "Move Down" })
set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi",                                   { desc = "Move Up" })
set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv",       { desc = "Move Down" })
set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
set("x", "n", "'Nn'[v:searchforward]",      { expr = true, desc = "Next Search Result" })
set("o", "n", "'Nn'[v:searchforward]",      { expr = true, desc = "Next Search Result" })
set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
set("x", "N", "'nN'[v:searchforward]",      { expr = true, desc = "Prev Search Result" })
set("o", "N", "'nN'[v:searchforward]",      { expr = true, desc = "Prev Search Result" })

-- Resize window using <ctrl> arrow keys
set("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase Window Height" })
set("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease Window Height" })
set("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
