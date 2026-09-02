Config.on_event({ "BufReadPost", "BufNewFile" }, function()
	local base_plugins = {
		"https://github.com/nvim-neotest/neotest",
		"https://github.com/nvim-neotest/nvim-nio",
		"https://github.com/nvim-lua/plenary.nvim",
	}

	local function plugin_url(plugin)
		if plugin:match("^https?://") then
			return plugin
		end
		return "https://github.com/" .. plugin
	end

	local function module_name(plugin)
		return plugin:gsub("%.git$", ""):match("([^/]+)$")
	end

	local function normalize_runner(runner)
		if type(runner) == "string" then
			return {
				plugin = runner,
				module = module_name(runner),
			}
		end

		local plugin = runner.plugin or runner[1]
		return {
			plugin = plugin,
			module = runner.module or module_name(plugin),
			opts = runner.opts,
		}
	end

	local function has_trouble()
		local ok, trouble = pcall(require, "trouble")
		return ok and trouble or nil
	end

	local function load_adapter(runner)
		local ok, adapter = pcall(require, runner.module)
		if not ok then
			vim.notify("Failed to load neotest adapter: " .. runner.module, vim.log.levels.WARN)
			return nil
		end

		local opts = runner.opts or {}
		if type(adapter) == "function" then
			return adapter(opts)
		end

		if type(opts) == "table" and not vim.tbl_isempty(opts) then
			local meta = getmetatable(adapter)
			if adapter.setup then
				adapter.setup(opts)
			elseif adapter.adapter then
				adapter.adapter(opts)
				adapter = adapter.adapter
			elseif meta and meta.__call then
				adapter = adapter(opts)
			else
				vim.notify("Adapter " .. runner.module .. " does not support setup", vim.log.levels.WARN)
			end
		end

		return adapter
	end

	local function setup()
		local runners = require("lang").get().test_runners
		local specs = vim.deepcopy(base_plugins)
		local adapters = {}
		local normalized = {}

		for _, runner in ipairs(runners) do
			local item = normalize_runner(runner)
			if item.plugin and item.module then
				table.insert(normalized, item)
				table.insert(specs, plugin_url(item.plugin))
			end
		end

		vim.pack.add(specs)

		for _, runner in ipairs(normalized) do
			local adapter = load_adapter(runner)
			if adapter then
				table.insert(adapters, adapter)
			end
		end

		local neotest_ns = vim.api.nvim_create_namespace("neotest")
		vim.diagnostic.config({
			virtual_text = {
				format = function(diagnostic)
					return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
				end,
			},
		}, neotest_ns)

		---@diagnostic disable-next-line: missing-fields
		local opts = {
			adapters = adapters,
			floating = {
				border = "bold",
				max_height = 0.9,
				max_width = 0.95,
				options = {
					wrap = false,
				},
			},
			status = {
				enabled = true,
				signs = true,
				virtual_text = true,
			},
			output = {
				enabled = true,
				open_on_run = true,
			},
			quickfix = {
				open = function()
					local trouble = has_trouble()
					if trouble then
						trouble.open({ mode = "quickfix", focus = false })
					else
						vim.cmd("copen")
					end
				end,
			},
		}

		if has_trouble() then
			opts.consumers = opts.consumers or {}
			opts.consumers.trouble = function(client)
				client.listeners.results = function(adapter_id, results, partial)
					if partial then
						return
					end

					local tree = assert(client:get_position(nil, { adapter = adapter_id }))
					local failed = 0
					for pos_id, result in pairs(results) do
						if result.status == "failed" and tree:get_key(pos_id) then
							failed = failed + 1
						end
					end

					vim.schedule(function()
						local trouble = has_trouble()
						if trouble and trouble.is_open() then
							trouble.refresh()
							if failed == 0 then
								trouble.close()
							end
						end
					end)

					return {}
				end
			end
		end

		require("neotest").setup(opts)

		return true
	end

	local function neotest(fn)
		return function()
			if setup() then
				fn(require("neotest"))
			end
		end
	end

	local set = vim.keymap.set

-- stylua: ignore start
set("n", "<leader>tn", neotest(function(nt) nt.run.run() end),                                        { desc = "Run Nearest Test" })
set("n", "<leader>tf", neotest(function(nt) nt.run.run(vim.fn.expand("%")) end),                      { desc = "Run Test File" })
set("n", "<leader>td", neotest(function(nt) nt.run.run({strategy = "dap"}) end),                      { desc = "Debug Nearest" })
set("n", "<leader>ta", neotest(function(nt) nt.run.run(vim.uv.cwd()) end),                            { desc = "Run All Tests" })
set("n", "<leader>tl", neotest(function(nt) nt.run.run_last() end),                                   { desc = "Run Last Test" })
set("n", "<leader>ts", neotest(function(nt) nt.summary.toggle() end),                                 { desc = "Toggle Test Summary" })
set("n", "<leader>to", neotest(function(nt) nt.output.open({ enter = true, auto_close = true }) end), { desc = "Show Test Output" })
set("n", "<leader>tO", neotest(function(nt) nt.output_panel.toggle() end),                            { desc = "Toggle Test Output Panel" })
set("n", "<leader>tS", neotest(function(nt) nt.run.stop() end),                                       { desc = "Stop Test" })
set("n", "<leader>tw", neotest(function(nt) nt.watch.toggle(vim.fn.expand("%")) end),                 { desc = "Toggle Watch (Neotest)" })
	-- stylua: ignore end
end)
