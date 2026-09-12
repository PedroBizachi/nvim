Config.later(function()
	vim.pack.add({ "https://github.com/folke/which-key.nvim" })

	local wk = require("which-key")
	local function mini_ai_textobjects()
		local objects = {
			{ " ", desc = "whitespace" },
			{ '"', desc = '" string' },
			{ "'", desc = "' string" },
			{ "(", desc = "() block" },
			{ ")", desc = "() block with ws" },
			{ "<", desc = "<> block" },
			{ ">", desc = "<> block with ws" },
			{ "?", desc = "user prompt" },
			{ "U", desc = "use/call without dot" },
			{ "[", desc = "[] block" },
			{ "]", desc = "[] block with ws" },
			{ "_", desc = "underscore" },
			{ "`", desc = "` string" },
			{ "a", desc = "argument" },
			{ "b", desc = ")]} block" },
			{ "c", desc = "class" },
			{ "d", desc = "digit(s)" },
			{ "e", desc = "CamelCase / snake_case" },
			{ "f", desc = "function" },
			{ "g", desc = "entire file" },
			{ "i", desc = "indent" },
			{ "o", desc = "block, conditional, loop" },
			{ "q", desc = "quote `\"'" },
			{ "t", desc = "tag" },
			{ "u", desc = "use/call" },
			{ "{", desc = "{} block" },
			{ "}", desc = "{} with ws" },
		}
		local groups = {
			{ prefix = "a", name = "around" },
			{ prefix = "i", name = "inside" },
			{ prefix = "an", name = "around next" },
			{ prefix = "in", name = "inside next" },
			{ prefix = "al", name = "around last" },
			{ prefix = "il", name = "inside last" },
		}
		local ret = { mode = { "o", "x" } }

		for _, group in ipairs(groups) do
			table.insert(ret, { group.prefix, group = group.name })
			for _, object in ipairs(objects) do
				table.insert(ret, { group.prefix .. object[1], desc = group.name .. " " .. object.desc })
			end
		end

		return ret
	end

	local ft_icon = function()
		return { cat = "filetype", name = vim.bo.filetype }
	end

	local has_lsp = function()
		return #vim.lsp.get_clients({ bufnr = 0 }) > 0
	end

	local lsp_key = function(lhs, desc)
		return { lhs, desc = desc, icon = ft_icon, cond = has_lsp }
	end

	wk.setup({
		delay = 0,
		preset = "helix",
		sort = { "local", "order", "group", "alphanum", "mod" },
		icons = {
			rules = {
				{ pattern = "opencode", icon = "󰚩", color = "cyan" },
				{ pattern = "rest", icon = "󰖟", color = "blue" },
				{ pattern = "mason", icon = "󰏖", color = "blue" },
				{ pattern = "grep", icon = "󰱼 ", color = "green" },
				{ pattern = "github", icon = " ", color = "purple" },
				{ pattern = "lazygit", cat = "filetype", name = "git" },
				{ pattern = "branch", cat = "filetype", name = "git" },
				{ pattern = "stash", cat = "filetype", name = "git" },
				{ pattern = "hunk", cat = "filetype", name = "git" },
				{ pattern = "symbol", icon = "󰔶 ", color = "orange" },
				{ pattern = "log", icon = " ", color = "yellow" },
				{ pattern = "type", icon = "󰆩 ", color = "yellow" },
				{ pattern = "call", icon = "󰃷 ", color = "blue" },
				{ pattern = "hover", icon = "󰋖 ", color = "cyan" },
				{ pattern = "colorscheme", icon = " ", color = "cyan" },
				{ pattern = "undo", icon = "󰕌 ", color = "yellow" },
				{ pattern = "jump", icon = "󰁔 ", color = "blue" },
				{ pattern = "markdown", icon = " ", color = "cyan" },
				{ pattern = "render", icon = "󰦨 ", color = "cyan" },
				{ pattern = "mark", icon = "󰃀 ", color = "yellow" },
				{ pattern = "quickfix", icon = "󱖫 ", color = "green" },
				{ pattern = "location", icon = "󰍎 ", color = "blue" },
				{ pattern = "register", icon = "󰘓 ", color = "orange" },
				{ pattern = "command", icon = " ", color = "blue" },
				{ pattern = "cmdline", icon = " ", color = "blue" },
				{ pattern = "help", icon = "󰋖 ", color = "cyan" },
				{ pattern = "man", icon = "󰋖 ", color = "cyan" },
				{ pattern = "icon", icon = "󰀻 ", color = "purple" },
				{ pattern = "keymap", icon = " ", color = "purple" },
				{ pattern = "autocmd", icon = "󰑓 ", color = "orange" },
				{ pattern = "highlight", icon = "󰸱 ", color = "yellow" },
				{ pattern = "project", icon = "󰏗 ", color = "blue" },
				{ pattern = "recent", icon = "󰋚 ", color = "cyan" },
				{ pattern = "resume", icon = "󰑓 ", color = "green" },
				{ pattern = "inspect", icon = "󰆈 ", color = "yellow" },
				{ pattern = "spell", icon = "󰓆 ", color = "green" },
				{ pattern = "wrap", icon = "󰖶 ", color = "cyan" },
				{ pattern = "conceal", icon = "󰈉 ", color = "grey" },
				{ pattern = "tree", icon = "󰙅 ", color = "green" },
				{ pattern = "scroll", icon = "󰹹 ", color = "blue" },
				{ pattern = "save", icon = " ", color = "azure" },
				{ pattern = "split", icon = " ", color = "blue" },
				{ pattern = "move", icon = "󰆾 ", color = "purple" },
				{ pattern = "duplicate", icon = " ", color = "orange" },
				{ pattern = "indent", icon = "󰉶 ", color = "purple" },
				{ pattern = "open", icon = "󰏋 ", color = "blue" },
				{ pattern = "restart", icon = "󰑓 ", color = "orange" },
				{ pattern = "redraw", icon = " ", color = "cyan" },
				{ pattern = "lua", cat = "filetype", name = "lua" },
				{ pattern = "todo", icon = " ", color = "orange" },
			},
		},
		spec = {
			-- stylua: ignore start
			mode = { "n", "x" },
			{ "<leader>l",  group = "log" },
			{ "<leader>a",  group = "ai" },
			{ "<leader>R",  group = "rest" },
			{ "<leader>c",  group = "code" },
			{ "<leader>d",  group = "debug" },
			{ "<leader>dp", group = "profiler" },
			{ "<leader>f",  group = "file/find" },
			{ "<leader>fm", group = "format" },
			{ "<leader>g",  group = "git" },
			{ "<leader>gh", group = "hunks" },
			{ "<leader>q",  group = "quit/session" },
			{ "<leader>s",  group = "search" },
			{ "<leader>sn", group = "notifications" },
			{ "<leader>t",  group = "test" },
			{ "<leader>u",  group = "ui" },
			{ "<leader>x",  group = "diagnostics/quickfix" },
			{ "[",          group = "prev" },
			{ "]",          group = "next" },
			{ "g",          group = "goto" },
			lsp_key("gd", "Goto Definition"),
			lsp_key("gD", "Goto Declaration"),
			lsp_key("gr", "References"),
			lsp_key("gI", "Goto Implementation"),
			lsp_key("gy", "Goto T[y]pe Definition"),
			lsp_key("gai", "C[a]lls Incoming"),
			lsp_key("gao", "C[a]lls Outgoing"),
			lsp_key("K", "Hover"),
			lsp_key("gK", "Signature Help"),
			lsp_key("]]", "Next Reference"),
			lsp_key("[[", "Prev Reference"),
			lsp_key("<leader>ca", "Code Action"),
			lsp_key("<leader>cA", "Source Action"),
			lsp_key("<leader>cc", "Run Codelens"),
			lsp_key("<leader>cl", "Lsp Info"),
			lsp_key("<leader>co", "Organize Imports"),
			lsp_key("<leader>cr", "Rename"),
			lsp_key("<leader>cR", "Rename File"),
			{ "gs", group = "surround" },
			{ "z",  group = "fold" },
			{
				"<leader>b",
				group = "buffer",
				expand = function()
					return require("which-key.extras").expand.buf()
				end,
			},
			{
				"<leader>w",
				group = "windows",
				proxy = "<c-w>",
				expand = function()
					return require("which-key.extras").expand.win()
				end,
			},
			-- better descriptions
			{ "gx", desc = "Open with system app" },
		},
	})
	wk.add(mini_ai_textobjects())
end)
