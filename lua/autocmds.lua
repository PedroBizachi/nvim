local function augroup(name)
	return vim.api.nvim_create_augroup("bizak_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Open 'help' pages in vertical split
vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	command = "wincmd L"
})

-- Install stdsym after installing/updating godoc
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if
      ev.data.spec.name == "godoc.nvim"
      and (ev.data.kind == "install" or ev.data.kind == "update")
    then
      vim.system({
        "go",
        "install",
        "github.com/lotusirous/gostdsym/stdsym@latest",
      }):wait()
    end
  end,
})

-- no auto continue comments on new line
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("no_auto_comment", {}),
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- Start recording macro
vim.api.nvim_create_autocmd("RecordingEnter", {
	desc = "Simple notify when recording a macro",
	pattern = "*",
	callback = function()
		local register = vim.fn.reg_recording()
		if register ~= "" then
			vim.notify("Gravando macro [@" .. register .. "]", vim.log.levels.WARN)
		end
	end,
})

-- Leave recording macro
vim.api.nvim_create_autocmd("RecordingLeave", {
	desc = "Notificação simples ao encerrar gravação de macro",
	pattern = "*",
	callback = function()
		vim.notify("Gravação de macro concluída", vim.log.levels.INFO)
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		if vim.fn.has("nvim-0.13") == 1 then
			vim.hl.hl_op()
		else
			(vim.hl or vim.highlight).on_yank()
		end
	end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].bizak_last_loc then
			return
		end
		vim.b[buf].bizak_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dap-float",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("man_unlisted"),
	pattern = { "man" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
	group = augroup("json_conceal"),
	pattern = { "json", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- === USERCMDS ===

vim.api.nvim_create_user_command("Restart", function()
	vim.cmd([[restart lua vim.schedule(function() vim.cmd("filetype detect") end)]])
end, { desc = "Restart Neovim and detect the restored buffer's filetype" })

-- NOTE: Pack commands enhanced
vim.api.nvim_create_user_command("PackAdd", function(opts)
	vim.pack.add(opts.fargs)
end, { nargs = "+", desc = "Add plugins (PackAdd user/repo)" })

vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
end, { desc = "Update all plugins" })

vim.api.nvim_create_user_command("PackDel", function(opts)
	vim.pack.del(opts.fargs)
end, { nargs = "+", desc = "Deletes plugins (space separated)" })

local function get_non_active_plugins()
	return vim.iter(vim.pack.get())
		:filter(function(x)
			return not x.active
		end)
		:map(function(x)
			return x.spec.name
		end)
		:totable()
end

local function delete_non_active_plugins(plugins)
	if #plugins == 0 then
		return
	end

	vim.pack.del(plugins, { force = true })
	vim.notify("  Deleted " .. #plugins .. " non-active plugin(s)", vim.log.levels.INFO)
	print("Non-active plugins deleted!")
	vim.api.nvim_exec_autocmds("User", { pattern = "PackChanged" })
end

local function pick_non_active_plugins(non_active)
	if package.loaded.snacks and Snacks.picker then
		local items = vim.tbl_map(function(name)
			return { text = name, name = name }
		end, non_active)

		Snacks.picker({
			title = "Pick inactive plugins to delete",
			items = items,
			format = "text",
			confirm = function(picker)
				local plugins = vim.tbl_map(function(item)
					return item.name
				end, picker:selected({ fallback = true }))

				picker:close()
				delete_non_active_plugins(plugins)
			end,
		})
		return
	end

	vim.ui.select(non_active, { prompt = "Delete inactive plugin:" }, function(plugin)
		if plugin then
			delete_non_active_plugins({ plugin })
		else
			vim.notify("Cancelled. No plugins were deleted!", vim.log.levels.INFO)
		end
	end)
end

vim.api.nvim_create_user_command("PackCheck", function()
	local non_active = get_non_active_plugins()

	if #non_active == 0 then
		vim.notify("  No non-active plugins found!", vim.log.levels.INFO)
		return
	end

	vim.print("󰒲  Non-active plugins: ")
	print(" ")
	for _, name in ipairs(non_active) do
		print(name)
	end

	print(" ")

	local choice = vim.fn.confirm("Delete non-active plugins from disk?", "&All\n&Pick\n&No", 3)

	if choice == 1 then
		delete_non_active_plugins(non_active)
	elseif choice == 2 then
		pick_non_active_plugins(non_active)
	else
		vim.notify("Cancelled. No plugins were deleted!", vim.log.levels.INFO)
	end
end, { desc = "List non-active plugins and select plugins to delete" })
