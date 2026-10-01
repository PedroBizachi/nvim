local function url_encode(value)
	return value:gsub("([^%w%-_%.~])", function(char)
		return string.format("%%%02X", string.byte(char))
	end)
end

local function strip_ansi(value)
	return value:gsub("\27%[[0-9;?]*[ -/]*[@-~]", ""):gsub("\r", "")
end

local function list_topics(value)
	return vim.tbl_filter(function(topic)
		return topic ~= ":list" and topic:sub(-6) ~= "/:list"
	end, vim.split(strip_ansi(value), "\n", { plain = true, trimempty = true }))
end

local ansi_namespace = vim.api.nvim_create_namespace("cheatsh.ansi")
local ansi_highlights = {}
local ansi_fallbacks = {
	"Comment",
	"DiagnosticError",
	"String",
	"DiagnosticWarn",
	"Identifier",
	"Special",
	"Type",
	"Normal",
}

local function ansi_color(index)
	if index < 16 then
		local color = vim.g["terminal_color_" .. index]
		if color then
			return color
		end

		local fallback = vim.api.nvim_get_hl(0, { name = ansi_fallbacks[index % 8 + 1], link = false })
		return fallback.fg and string.format("#%06x", fallback.fg) or nil
	end

	if index < 232 then
		local level = { 0, 95, 135, 175, 215, 255 }
		local color = index - 16
		local red = level[math.floor(color / 36) + 1]
		local green = level[math.floor(color % 36 / 6) + 1]
		local blue = level[color % 6 + 1]
		return string.format("#%02x%02x%02x", red, green, blue)
	end

	local gray = 8 + (index - 232) * 10
	return string.format("#%02x%02x%02x", gray, gray, gray)
end

local function ansi_highlight(state)
	local key = table.concat({
		state.fg or "",
		state.bg or "",
		state.bold and "bold" or "",
		state.italic and "italic" or "",
		state.underline and "underline" or "",
		state.reverse and "reverse" or "",
	}, ":")
	if key == ":::::" then
		return
	end
	if ansi_highlights[key] then
		return ansi_highlights[key]
	end

	local name = "CheatshAnsi" .. #vim.tbl_keys(ansi_highlights)
	vim.api.nvim_set_hl(0, name, {
		fg = state.fg and ansi_color(state.fg) or nil,
		bg = state.bg and ansi_color(state.bg) or nil,
		bold = state.bold or nil,
		italic = state.italic or nil,
		underline = state.underline or nil,
		reverse = state.reverse or nil,
	})
	ansi_highlights[key] = name
	return name
end

local function apply_ansi_codes(state, params)
	local codes = vim.split(params == "" and "0" or params, ";", { plain = true })
	local index = 1
	while index <= #codes do
		local code = tonumber(codes[index]) or 0
		if code == 0 then
			state.fg, state.bg = nil, nil
			state.bold, state.italic, state.underline, state.reverse = nil, nil, nil, nil
		elseif code == 1 then
			state.bold = true
		elseif code == 3 then
			state.italic = true
		elseif code == 4 then
			state.underline = true
		elseif code == 7 then
			state.reverse = true
		elseif code == 22 then
			state.bold = nil
		elseif code == 23 then
			state.italic = nil
		elseif code == 24 then
			state.underline = nil
		elseif code == 27 then
			state.reverse = nil
		elseif code >= 30 and code <= 37 then
			state.fg = code - 30
		elseif code >= 90 and code <= 97 then
			state.fg = code - 90 + 8
		elseif code == 39 then
			state.fg = nil
		elseif code >= 40 and code <= 47 then
			state.bg = code - 40
		elseif code >= 100 and code <= 107 then
			state.bg = code - 100 + 8
		elseif code == 49 then
			state.bg = nil
		elseif (code == 38 or code == 48) and codes[index + 1] == "5" and tonumber(codes[index + 2]) then
			local color = tonumber(codes[index + 2])
			state[code == 38 and "fg" or "bg"] = color
			index = index + 2
		end
		index = index + 1
	end
end

local function ansi_lines(value)
	local lines, marks, state = { "" }, {}, {}
	local cursor = 1
	local function append(text)
		local parts = vim.split(text, "\n", { plain = true, trimempty = false })
		for i, part in ipairs(parts) do
			if #part > 0 then
				local row, col = #lines - 1, #lines[#lines]
				lines[#lines] = lines[#lines] .. part
				local highlight = ansi_highlight(state)
				if highlight then
					marks[#marks + 1] = { row = row, col = col, end_col = col + #part, hl_group = highlight }
				end
			end
			if i < #parts then
				lines[#lines + 1] = ""
			end
		end
	end

	value = value:gsub("\r", "")
	for start, params, finish in value:gmatch("()\27%[([0-9;]*)m()") do
		append(value:sub(cursor, start - 1))
		apply_ansi_codes(state, params)
		cursor = finish
	end
	append(value:sub(cursor))
	return lines, marks
end

local function set_ansi_lines(buf, value)
	local lines, marks = ansi_lines(value)
	local modifiable = vim.bo[buf].modifiable
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_clear_namespace(buf, ansi_namespace, 0, -1)
	for _, mark in ipairs(marks) do
		vim.api.nvim_buf_set_extmark(buf, ansi_namespace, mark.row, mark.col, {
			end_col = mark.end_col,
			hl_group = mark.hl_group,
		})
	end
	vim.bo[buf].modifiable = modifiable
end

local cheatsh_targets = {
	{ key = "p", path = "python", filetype = "python", name = "Python" },
	{ key = "g", path = "go", filetype = "go", name = "Go" },
	{ key = "<Space>", path = "", filetype = "text", name = "Global" },
}

local function cheat_url(target, query)
	if target.path == "" then
		return "cheat.sh/" .. url_encode(query)
	end

	return "cheat.sh/" .. target.path .. "/" .. url_encode(query)
end

local function show_cheat(target, query, result)
	vim.cmd("vnew")
	vim.cmd("wincmd L")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_name(buf, "cheat://" .. (target.path ~= "" and target.path or "global") .. "/" .. query)
	set_ansi_lines(buf, result)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].filetype = target.filetype
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	vim.bo[buf].swapfile = false
	vim.cmd("normal! gg")
end

local function request_cheat(target, query, callback)
	return vim.system({
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
			callback(result)
		end)
	end)
end

local function fetch_cheat(target, query)
	request_cheat(target, query, function(result)
		if result.code ~= 0 then
			vim.notify(result.stderr ~= "" and result.stderr or "cheat.sh returned no result", vim.log.levels.ERROR)
			return
		end
		show_cheat(target, query, result.stdout)
	end)
end

local function preview_cheat(ctx)
	if ctx.item.cheat then
		ctx.preview:reset()
		set_ansi_lines(ctx.buf, ctx.item.cheat)
		return ctx.preview:highlight({ ft = ctx.item.target.filetype })
	end

	ctx.preview:reset()
	ctx.preview:set_lines({ "Loading " .. ctx.item.text .. "..." })
	request_cheat(ctx.item.target, ctx.item.query, function(result)
		if ctx.preview.item ~= ctx.item then
			return
		end
		if result.code ~= 0 then
			ctx.preview:notify(
				result.stderr ~= "" and result.stderr or "cheat.sh returned no result",
				"error",
				{ item = false }
			)
			return
		end

		ctx.item.cheat = result.stdout
		ctx.preview:reset()
		set_ansi_lines(ctx.buf, ctx.item.cheat)
		ctx.preview:highlight({ ft = ctx.item.target.filetype })
	end)
end

local function open_topic_picker(target, result)
	local prefix = target.path .. "/"
	local items = vim.tbl_map(function(topic)
		local query = vim.startswith(topic, prefix) and topic:sub(#prefix + 1) or topic
		return { text = topic, query = query, target = target }
	end, list_topics(result))

	Snacks.picker.pick({
		title = "cheat.sh/" .. target.path,
		items = items,
		format = "text",
		preview = preview_cheat,
		confirm = function(picker, item)
			picker:close()
			if item then
				fetch_cheat(item.target, item.query)
			end
		end,
	})
end

local function fetch_topic_list(target)
	request_cheat(target, ":list", function(result)
		if result.code ~= 0 then
			vim.notify(result.stderr ~= "" and result.stderr or "cheat.sh returned no result", vim.log.levels.ERROR)
			return
		end
		open_topic_picker(target, result.stdout)
	end)
end

local function open_namespace_picker(result)
	local items = vim.tbl_map(function(namespace)
		return { text = namespace }
	end, list_topics(result))

	Snacks.picker.pick({
		title = "cheat.sh/",
		items = items,
		format = "text",
		layout = { preview = false },
		confirm = function(picker, item)
			picker:close()
			if item then
				if item.text:sub(-1) == "/" then
					fetch_topic_list({ path = item.text:gsub("/$", ""), filetype = "text", name = item.text })
				else
					fetch_cheat(cheatsh_targets[3], item.text)
				end
			end
		end,
	})
end

local function open_picker(target)
	return function()
		if target.path == "" then
			request_cheat(target, ":list", function(result)
				if result.code ~= 0 then
					vim.notify(
						result.stderr ~= "" and result.stderr or "cheat.sh returned no result",
						vim.log.levels.ERROR
					)
					return
				end
				open_namespace_picker(result.stdout)
			end)
		else
			fetch_topic_list(target)
		end
	end
end

local function register_which_key()
	local ok, wk = pcall(require, "which-key")
	if not ok then
		return
	end

	wk.add({
		{ "<leader>csc", group = "cheat.sh" },
	})
end

vim.api.nvim_create_user_command("Cheat", open_picker(cheatsh_targets[3]), { desc = "Search cheat.sh" })

for _, target in ipairs(cheatsh_targets) do
	vim.keymap.set(
		"n",
		"<leader>csc" .. target.key,
		open_picker(target),
		{ desc = "Search " .. target.name .. " on cheat.sh" }
	)
end

Config.later(function()
	vim.schedule(register_which_key)
end)
