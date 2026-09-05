local function url_encode(value)
	return value:gsub("([^%w%-_%.~])", function(char)
		return string.format("%%%02X", string.byte(char))
	end)
end

local function strip_ansi(value)
	return value:gsub("\27%[[0-9;?]*[ -/]*[@-~]", ""):gsub("\r", "")
end

local cheatsh_targets = {
	{ key = "p", path = "python", filetype = "python", name = "Python" },
	{ key = "g", path = "go", filetype = "go", name = "Go" },
	{ key = "c", path = "", filetype = "text", name = "Global" },
}

local function cheat_url(target, query)
	if target.path == "" then
		return "https://cht.sh/" .. url_encode(query)
	end

	return "https://cht.sh/" .. target.path .. "/" .. url_encode(query)
end

local function show_cheat(target, query, result)
	vim.cmd("vnew")
	vim.cmd("wincmd L")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_name(buf, "cheat://" .. (target.path ~= "" and target.path or "global") .. "/" .. query)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(strip_ansi(result), "\n", { plain = true }))
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].filetype = target.filetype
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	vim.bo[buf].swapfile = false
	vim.cmd("normal! gg")
end

local function fetch_cheat(target, query)
	vim.system({
		"curl",
		"--fail-with-body",
		"--silent",
		"--show-error",
		"--location",
		"--connect-timeout",
		"5",
		"--max-time",
		"15",
		cheat_url(target, query),
	}, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				vim.notify(result.stderr ~= "" and result.stderr or "cheat.sh returned no result", vim.log.levels.ERROR)
				return
			end
			show_cheat(target, query, result.stdout)
		end)
	end)
end

local function cheatsh(target)
	return function()
		vim.ui.input({
			prompt = target.name .. " query: ",
			default = vim.fn.expand("<cword>"),
		}, function(query)
			if query and query:match("%S") then
				fetch_cheat(target, query)
			end
		end)
	end
end

local function register_which_key()
	local ok, wk = pcall(require, "which-key")
	if not ok then
		return
	end

	wk.add({
		{ "<leader>sp", group = "cheat.sh" },
	})
end

vim.api.nvim_create_user_command("Cheat", cheatsh(cheatsh_targets[3]), { desc = "Search cheat.sh" })

for _, target in ipairs(cheatsh_targets) do
	vim.keymap.set("n", "<leader>sp" .. target.key, cheatsh(target), { desc = "Search " .. target.name .. " on cheat.sh" })
end

Config.later(function()
	vim.schedule(register_which_key)
end)
