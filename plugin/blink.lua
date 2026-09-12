Config.on_event({ "BufReadPre", "BufNewFile" }, function()
	vim.pack.add({
		"https://github.com/saghen/blink.lib",
		"https://github.com/saghen/blink.cmp",
		"https://github.com/Huijiro/blink-cmp-supermaven",
		"https://github.com/rafamadriz/friendly-snippets",
		"https://github.com/L3MON4D3/LuaSnip",
		"https://github.com/saghen/blink.compat",
		"https://github.com/onsails/lspkind.nvim",
		"https://github.com/nvim-tree/nvim-web-devicons",
		"https://github.com/mikavilpas/blink-ripgrep.nvim",
	})

	require("luasnip").setup({})

	local cmp = require("blink-cmp")

	---@diagnostic disable-next-line: undefined-field
	cmp.build():pwait()

	---@type blink.cmp.WindowBorder
	local border = "bold"

	cmp.setup({
		snippets = {
			preset = "luasnip",
		},

		completion = {
			accept = {
				auto_brackets = {
					enabled = true,
					semantic_token_resolution = { enabled = false },
				},
				create_undo_point = true,
			},
			trigger = {
				show_on_trigger_character = true,
				show_on_insert_on_trigger_character = true,
				show_on_accept_on_trigger_character = true,
				show_on_blocked_trigger_characters = {},
			},
			menu = {
				auto_show = true,
				border = "none",
				draw = {
					treesitter = { "lsp" },
					columns = {
						{ "kind_icon", "label", "label_description", gap = 1 },
						{ "kind", "source_name", gap = 1 },
					},
					components = {
						kind_icon = {
							ellipsis = false,
							text = function(ctx)
								local lspkind = require("lspkind")
								local icon = ctx.kind_icon
								local own_icon = Config.icons["kinds"]
								if vim.tbl_contains({ "Path" }, ctx.source_name) then
									local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
									if dev_icon then
										icon = dev_icon
									end
								else
									if own_icon[ctx.kind] then
										icon = own_icon[ctx.kind]
									else
										icon = lspkind.symbol_map[ctx.kind] or ""
									end
								end

								return icon .. ctx.icon_gap
							end,
						},
					},
				},

				-- Change menu direction avoiding multi-line completion
				---@diagnostic disable-next-line: assign-type-mismatch
				direction_priority = function()
					local ctx = require("blink.cmp").get_context()
					local item = require("blink.cmp").get_selected_item()
					if ctx == nil or item == nil then
						return { "s", "n" }
					end

					local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
					local is_multi_line = item_text:find("\n") ~= nil

					-- after showing the menu upwards, we want to maintain that direction
					-- until we re-open the menu, so store the context id in a global variable
					if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
						vim.g.blink_cmp_upwards_ctx_id = ctx.id
						return { "n", "s" }
					end
					return { "s", "n" }
				end,
			},
			ghost_text = {
				enabled = true,
			},
			documentation = {
				window = { border = border },
				auto_show = true,
				auto_show_delay_ms = 0,
			},
		},

		-- experimental signature help support
		signature = {
			enabled = true,
			window = {
				border = border,
				show_documentation = true,
				direction_priority = { "n" },
			},
		},

		sources = {
			default = function()
				if vim.bo.filetype == "lua" then
					vim.cmd.packadd("lazydev.nvim")
					return { "lazydev", "lsp", "path", "snippets", "buffer", "ripgrep" }
				end

				return { "lsp", "path", "snippets", "buffer", "ripgrep" }
			end,
			per_filetype = {
				opencode_ask = { "lsp", "buffer" },
				sql = {"lsp", "snippets", "buffer" },
			},
			providers = {
				lsp = {
					name = "LSP",
					module = "blink.cmp.sources.lsp",
					score_offset = 90,
					fallbacks = {},
					async = true,
					timeout_ms = 0,
					min_keyword_length = 0,
					override = {
						get_trigger_characters = function(self)
							local trigger_characters = self:get_trigger_characters()
							vim.list_extend(trigger_characters, { "\n", "\t", " " })
							return trigger_characters
						end,
					},
				},
				buffer = {
					min_keyword_length = 3,
					max_items = 5,
					opts = {
						get_bufnrs = function()
							return vim.tbl_filter(function(bufnr)
								return vim.bo[bufnr].buftype == ""
							end, vim.api.nvim_list_bufs())
						end,
					},
				},
				snippets = {
					min_keyword_length = 2,
					max_items = 5,
					score_offset = 80,
					should_show_items = function(ctx)
						return ctx.trigger.initial_kind ~= "trigger_character"
					end,
				},
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100, -- show at a higher priority than lsp
				},
				supermaven = {
					name = "supermaven",
					module = "blink-cmp-supermaven",
					async = true,
				},
				ripgrep = {
					module = "blink-ripgrep",
					name = "Ripgrep",
					---@module "blink-ripgrep"
          ---@type blink-ripgrep.Options
          opts = {
						backend = {
							use = "gitgrep-or-ripgrep"
						},
					}
				}
			},
		},

		fuzzy = {
			implementation = "prefer_rust_with_warning",
			sorts = { "exact", "score", "sort_text" },
		},

		cmdline = {
			enabled = true,
			keymap = {
				preset = "cmdline",
				["<Right>"] = false,
				["<Left>"] = false,
			},
			completion = {
				list = { selection = { preselect = false } },
				menu = {
					auto_show = function(ctx)
						return vim.fn.getcmdtype() == ":"
					end,
				},
				ghost_text = { enabled = true },
			},
		},

		keymap = {
			preset = "default",
			["<C-l>"] = { "show", "show_documentation", "hide_documentation", "hide" },
			["<Tab>"] = {
				"select_next",
				"snippet_forward",
				function()
					local preview = require("supermaven-nvim.completion_preview")
					if preview.has_suggestion() then
						preview.on_accept_suggestion()
						return true
					end
				end,
				"fallback",
			},
			["<CR>"] = {'accept', 'fallback'},
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			["<Esc>"] = { "cancel", "fallback" },
		},
	})
	require("luasnip.loaders.from_vscode").lazy_load()
end)
