Config.later(function()
	vim.pack.add({
		"https://github.com/MunifTanjim/nui.nvim",
		"https://github.com/kndndrj/nvim-dbee",
	})

	require("dbee").install()
	require("dbee").setup()

	-- === KEYMAPS ===
	local set = vim.keymap.set

  -- stylua: ignore start
  set({"n", "x"}, "<leader>db", "<cmd>Dbee<cr>", { desc = "Open database client" })
end)
