Config.on_event({ "BufReadPre", "BufNewFile" }, function()
	vim.g.matchup_matchparen_enabled = 1
	vim.g.matchup_matchparen_deferred = 1
	vim.g.matchup_treesitter_enabled = true
	vim.g.matchup_treesitter_enable_quotes = false
	vim.g.matchup_treesitter_stopline = 100
	vim.g.matchup_matchparen_offscreen = {}

	-- Define hook to update tree-sitter parsers after plugin is updated
	local ts_update = function()
		vim.cmd("TSUpdate")
	end
	Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

	vim.pack.add({
		"https://github.com/nvim-treesitter/nvim-treesitter",
		"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
		"https://github.com/andymass/vim-matchup",
		"https://github.com/fredrikaverpil/tree-sitter-godoc",
	})

	local parsers = require("lang").get().treesitter

	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, parsers)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Enable tree-sitter after opening a file for a target language
	local filetypes = {}
	for _, lang in ipairs(parsers) do
		for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
			table.insert(filetypes, ft)
		end
	end

	local ts_start = function(ev)
		local ok = pcall(vim.treesitter.start, ev.buf)
		if not ok then
			return
		end

		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.wo.foldmethod = "expr"
		vim.wo.foldlevel = 1

		local parser_ok, parser = pcall(vim.treesitter.get_parser, ev.buf)
		local lang = parser_ok and parser:lang() or nil
		local query_ok, query = lang and pcall(vim.treesitter.query.get, lang, "indents")
		if query_ok and query ~= nil then
			vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end

	Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")

	require("nvim-treesitter-textobjects").setup({
		move = {
			set_jumps = true,
		},
	})

	local textobject_moves = {
		goto_next_start = {
			["]f"] = "@function.outer",
			["]c"] = "@class.outer",
			["]a"] = "@parameter.inner",
		},
		goto_next_end = {
			["]F"] = "@function.outer",
			["]C"] = "@class.outer",
			["]A"] = "@parameter.inner",
		},
		goto_previous_start = {
			["[f"] = "@function.outer",
			["[c"] = "@class.outer",
			["[a"] = "@parameter.inner",
		},
		goto_previous_end = {
			["[F"] = "@function.outer",
			["[C"] = "@class.outer",
			["[A"] = "@parameter.inner",
		},
	}

	local textobject_names = {
		["@function.outer"] = "Function",
		["@class.outer"] = "Class",
		["@parameter.inner"] = "Parameter",
	}

	local has_textobjects = function(buf)
		local ok, parser = pcall(vim.treesitter.get_parser, buf)
		return ok and vim.treesitter.query.get(parser:lang(), "textobjects") ~= nil
	end

	local attach_textobjects = function(buf)
		if not has_textobjects(buf) then
			return
		end

		local move = require("nvim-treesitter-textobjects.move")
		for method, keymaps in pairs(textobject_moves) do
			for key, query in pairs(keymaps) do
				local desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. textobject_names[query]
				desc = desc .. (key:sub(2, 2):match("%u") and " End" or " Start")

				vim.keymap.set({ "n", "x", "o" }, key, function()
					if vim.wo.diff and key:find("[cC]") then
						return vim.cmd("normal! " .. key)
					end
					move[method](query, "textobjects")
				end, { buffer = buf, desc = desc, silent = true })
			end
		end
	end

	Config.new_autocmd("FileType", filetypes, function(ev)
		attach_textobjects(ev.buf)
	end, "Attach tree-sitter textobjects")
end)
