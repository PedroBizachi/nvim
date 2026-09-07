local M = {}

function M.apply()
	local set = vim.api.nvim_set_hl

	-- === PALLETS ===
	local oldworld = {
		default = {
			bg = "#161617",
			fg = "#c9c7cd",
			subtext1 = "#b4b1ba",
			subtext2 = "#9f9ca6",
			subtext3 = "#8b8693",
			subtext4 = "#6c6874",
			bg_dark = "#131314",
			black = "#27272a",
			red = "#ea83a5",
			green = "#90b99f",
			yellow = "#e6b99d",
			purple = "#aca1cf",
			magenta = "#e29eca",
			orange = "#f5a191",
			blue = "#92a2d5",
			cyan = "#85b5ba",
			gray0 = "#18181a",
			gray1 = "#1b1b1c",
			gray2 = "#2a2a2c",
			gray3 = "#313134",
			gray4 = "#3b3b3e",
			gray5 = "#444448",
			none = "NONE",
		},
		cooler = {
			bg = "#161617",
			fg = "#c8c7cd",
			subtext1 = "#b2b1ba",
			subtext2 = "#9c9ca6",
			subtext3 = "#888693",
			subtext4 = "#696874",
			bg_dark = "#131314",
			black = "#27282a",
			red = "#ea83bf",
			green = "#90b995",
			yellow = "#e6a79d",
			purple = "#a1a1cf",
			magenta = "#e29edb",
			orange = "#f5919a",
			blue = "#92b3d5",
			cyan = "#85bab2",
			gray0 = "#18181a",
			gray1 = "#1b1b1c",
			gray2 = "#2a2b2c",
			gray3 = "#313234",
			gray4 = "#3b3c3e",
			gray5 = "#444448",
			none = "NONE",
		},
		oled = {
			bg = "#000000",
			fg = "#c9c7cd",
			subtext1 = "#b4b1ba",
			subtext2 = "#9f9ca6",
			subtext3 = "#8b8693",
			subtext4 = "#6c6874",
			bg_dark = "#000000",
			black = "#161617",
			red = "#ea83a5",
			green = "#90b99f",
			yellow = "#e6b99d",
			purple = "#aca1cf",
			magenta = "#e29eca",
			orange = "#f5a191",
			blue = "#92a2d5",
			cyan = "#85b5ba",
			gray0 = "#000000",
			gray1 = "#18181a",
			gray2 = "#1b1b1c",
			gray3 = "#2a2a2c",
			gray4 = "#313134",
			gray5 = "#444448",
			none = "NONE",
		},
	}

	local kanagawa = {
		fujiWhite = "#DCD7BA",
		oldWhite = "#C8C093",
		sumiInk0 = "#16161D",
		sumiInk1 = "#1F1F28",
		sumiInk2 = "#2A2A37",
		sumiInk3 = "#363646",
		sumiInk4 = "#54546D",
		waveBlue1 = "#223249",
		waveBlue2 = "#2D4F67",
		winterGreen = "#2B3328",
		winterYellow = "#49443C",
		winterRed = "#43242B",
		winterBlue = "#252535",
		autumnGreen = "#76946A",
		autumnRed = "#C34043",
		autumnYellow = "#DCA561",
		samuraiRed = "#E82424",
		roninYellow = "#FF9E3B",
		dragonBlue = "#658594",
		fujiGray = "#727169",
		springViolet1 = "#938AA9",
		oniViolet = "#957FB8",
		crystalBlue = "#7E9CD8",
		springViolet2 = "#9CABCA",
		springBlue = "#7FB4CA",
		lightBlue = "#A3D4D5",
		waveAqua1 = "#6A9589",
		waveAqua2 = "#7AA89F",
		springGreen = "#98BB6C",
		boatYellow1 = "#938056",
		boatYellow2 = "#C0A36E",
		carpYellow = "#E6C384",
		sakuraPink = "#D27E99",
		waveRed = "#E46876",
		peachRed = "#FF5D62",
		surimiOrange = "#FFA066",
	}

	local monokai = {
		dark = "#19181a",
		black = "#221f22",
		red = "#ff6188",
		green = "#a9dc76",
		yellow = "#ffd866",
		orange = "#fc9867",
		cyan = "#78dce8",
		magenta = "#ab9df2",
		white = "#fcfcfa",
		d1 = "#c1c0c0",
		d2 = "#939293",
		d3 = "#727072",
		d4 = "#5b595c",
		d5 = "#403e41",
	}

	local tokyodark = {
		fg = "#A0A8CD",
		red = "#EE6D85",
		orange = "#F6955B",
		yellow = "#D7A65F",
		green = "#95C561",
		blue = "#7199EE",
		cyan = "#38A89D",
		purple = "#A485DD",
		grey = "#4A5057",
	}

	local vague = {
		bg = "#141415",
		inactiveBg = "#1c1c24",
		fg = "#cdcdcd",
		floatBorder = "#878787",
		line = "#252530",
		comment = "#606079",
		builtin = "#b4d4cf",
		func = "#c48282",
		string = "#e8b589",
		number = "#e0a363",
		property = "#c3c3d5",
		constant = "#aeaed1",
		parameter = "#bb9dbd",
		visual = "#333738",
		error = "#d8647e",
		warning = "#f3be7c",
		hint = "#7e98e8",
		operator = "#90a0b5",
		keyword = "#6e94b2",
		type = "#9bb4bc",
		search = "#405065",
		plus = "#7fa563",
		delta = "#f3be7c",
	}

	local nightowl = {
		fg = "#d6deeb",
		bg = "#021727",
		folded_bg = "#092135",
		cursor_fg = "#805a3e",
		cursor_bg = "#80a4c2",
		line_number_fg = "#4b6479",
		line_number_active_fg = "#c5e4fc",
		sign_add = "#9ccc65",
		sign_change = "#e2b93d",
		sign_delete = "#ef5350",
		indent_guide = "#1f395d",
		indent_guide_active = "#7e97ac",
		visual = "#1d3b53",
		match_paren = "#1e364a",
		search_blue = "#063e5d",
		incremental_search_blue = "#2E485C",
		error_red = "#ef5350",
		word_highlight = "#33384d",
		word_highlight_write = "#2f3350",
		changed = "#a2bffc",
		quickfix_line = "#0e293f",
		ui_border = "#5f7e97",
		ui_border2 = "#20395d",
		nvim_tree_file = "#89a4bb",
		nvim_tree_indent_marker = "#585858",
		tab_active_bg = "#0b2942",
		tab_inactive_bg = "#01111d",
		title = "#82b1ff",
		parameter = "#d7dbe0",
		string_delimiter = "#d9f5dd",
		dark = "#010d18",
		dark2 = "#021320",
		dark3 = "#99b76d23",
		white = "#ffffff",
		white2 = "#eeefff",
		dark_white = "#cccccc",
		gray = "#262a39",
		gray2 = "#d2dee7",
		gray3 = "#36414a",
		gray4 = "#d6deeb80",
		gray5 = "#969696",
		gray6 = "#7e97ac",
		light_blue = "#78ccf0",
		blue = "#82aaff",
		blue2 = "#0b253a",
		blue3 = "#122d42",
		blue4 = "#1b90dd4d",
		blue5 = "#234d70",
		blue6 = "#234d708c",
		blue7 = "#395a75",
		blue8 = "#5ca7e4",
		blue9 = "#5f7e9779",
		blue10 = "#697098",
		blue11 = "#8eace3",
		blue12 = "#b2ccd6",
		blue13 = "#072232",
		blue14 = "#273845",
		blue15 = "#169fff",
		green = "#c5e478",
		green2 = "#6CC85E",
		light_cyan = "#caece6",
		cyan = "#6ae9f0",
		cyan2 = "#7fdbca",
		cyan3 = "#7fdbcaff",
		cyan4 = "#80cbc4",
		cyan5 = "#baebe2",
		dark_cyan = "#637777",
		light_red = "#ff869a",
		red = "#ff5874",
		red2 = "#ff6363",
		red3 = "#ef535090",
		-- dark_red = "#ab0300f2",
		dark_red = "#ab0300",
		light_orange = "#ecc48d",
		orange = "#f78c6c",
		orange2 = "#ffcb8b",
		light_yellow = "#faf39f",
		yellow = "#ffd602",
		yellow2 = "#b39554",
		yellow3 = "#fad430",
		yellow4 = "#ffeb95",
		yellow5 = "#ffeb95cc",
		light_purple = "#a599e9",
		purple = "#7e57c2",
		purple2 = "#5166F0",
		purple3 = "#da70d6",
		purple4 = "#7986e7",
		dark_purple = "#2E2D5E",
		magenta = "#c792ea",
		magenta2 = "#c789d6",
		magenta3 = "#d1aaff",
		magenta4 = "#ff2c83",
		magenta5 = "#e2a2f433",
		magenta6 = "#f6bbe533",
	}

	local catppuccin = {
		accent = "#89b4fa",
		cursor = "#f5e0dc",
		foreground = "#cdd6f4",
		background = "#1e1e2e",
		selection_foreground = "#1e1e2e",
		selection_background = "#f5e0dc",
		color0 = "#45475a",
		color1 = "#f38ba8",
		color2 = "#a6e3a1",
		color3 = "#f9e2af",
		color4 = "#89b4fa",
		color5 = "#f5c2e7",
		color6 = "#94e2d5",
		color7 = "#bac2de",
		color8 = "#585b70",
		color9 = "#f38ba8",
		color10 = "#a6e3a1",
		color11 = "#f9e2af",
		color12 = "#89b4fa",
		color13 = "#f5c2e7",
		color14 = "#94e2d5",
		color15 = "#a6adc8",
	}

	local custom = {
		night_owl_bg = "#031728",
		night_owl_bg_float = "#010d18",
		border = "#5d7b93",
		white = "#ececea",
		dark = "#0b1320",
		green = "#afe8b2",
		diff = {
			add = "#193038",
			change = "#2f2b1e",
			delete = "#2e222b",
		},
		diagnostics = {
			Error = "#2e222b",
			Warn = "#2f2b2e",
			Info = "#192b38",
			Hint = "#1a2b32",
		},
	}

	-- stylua: ignore start

	-- === GENERAL ===
	set(0, "Folded", { fg = monokai.d4, bold = true })

	-- === DIAGNOSTICS ===
	set(0, "DiagnosticVirtualTextWarn",  { bg = custom.diagnostics.Warn,  fg = kanagawa.carpYellow,  bold = true })
	set(0, "DiagnosticVirtualTextError", { bg = custom.diagnostics.Error, fg = kanagawa.waveRed,     bold = true })
	set(0, "DiagnosticVirtualTextInfo",  { bg = custom.diagnostics.Info,  fg = kanagawa.waveAqua2,   bold = true })
	set(0, "DiagnosticVirtualTextHint",  { bg = custom.diagnostics.Hint,  fg = kanagawa.crystalBlue, bold = true })

	-- === Snacks ===
	set(0, "SnacksDiffAdd",           { fg = nightowl.sign_add,    bg = custom.diff.add    })
	set(0, "SnacksDiffAddLineNr",     { fg = nightowl.sign_add,    bg = custom.diff.add    })
	set(0, "SnacksDiffDelete",        { fg = nightowl.sign_delete, bg = custom.diff.delete })
	set(0, "SnacksDiffDeleteLineNr",  { fg = nightowl.sign_delete, bg = custom.diff.delete })
	set(0, "SnacksDiffChange",        { fg = nightowl.sign_change, bg = custom.diff.change })
	set(0, "SnacksDiffChangeLineNr",  { fg = nightowl.sign_change, bg = custom.diff.change })
	set(0, "SnacksDiffContext",       { fg = nightowl.sign_change, bg = custom.diff.change })
	set(0, "SnacksDiffContextLineNr", { fg = nightowl.sign_change, bg = custom.diff.change })

	-- === Treesitter ===
	-- set(0, "@variable", { fg = custom.white, italic = true })

	-- === Mini ===
	set(0, "MiniStatuslineModeNormal",   { fg = "#f8771a", bg = "#2a1f1f", bold = true })
	set(0, "MiniStatuslineModeTerminal", { fg = "#f8771a", bg = "#2a1f1f", bold = true })
	set(0, "MiniStatuslineDevinfo",      { fg = "white",   bg = "#0a0a0a", bold = true })
	set(0, "CmpItemKindSupermaven",      { fg = "#f8771a", bg = nil,       bold = true })
	set(0, "MiniTablineCurrent",         { fg = "#f8771a", bg = "#2a1f1f", bold = true })
	set(0, "MiniTablineVisible",         { fg = "#f8771a", bg = "#2a1f1f", bold = true })

	-- === StartupTime ===
	set(0, "StartupTimeStartupValue", { fg = monokai.yellow })

	-- === Flash ===
	set(0, "FlashLabel", { fg = catppuccin.color9, bg = nil })

	-- === BlinkCMP ===
	set(0, "BlinkCmpDocBorder",           { fg = catppuccin.foreground, bg = nil })
	set(0, "BlinkCmpMenuBorder",          { fg = catppuccin.foreground, bg = nil })
	set(0, "BlinkCmpSignatureHelpBorder", { fg = catppuccin.foreground, bg = nil })

	-- === Remove BG ===
	set(0, "WhichKeyBorder",    { link = 'FloatBorder' })
	set(0, "WhichKeyNormal",    { fg = custom.white, bg = nil })
	set(0, "WhichKeyTitle",     { fg = custom.white, bg = nil })
	set(0, "MasonNormal",       { fg = custom.white, bg = nil })
	set(0, "SnacksPicker",      { fg = custom.white, bg = nil })
	set(0, "SnacksPickerTitle", { fg = custom.white, bg = nil })
end

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = M.apply,
})

M.apply()

return M
-- stylua: ignore end
