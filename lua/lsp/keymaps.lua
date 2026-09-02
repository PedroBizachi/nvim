local M = {}

local function has(bufnr, method)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		if client:supports_method(method, bufnr) then
			return true
		end
	end
	return false
end

local function source_action(kind)
	return function()
		vim.lsp.buf.code_action({
			apply = true,
			context = {
				only = { kind },
				diagnostics = {},
			},
		})
	end
end

function M.on_attach(bufnr)
	local set = function(mode, lhs, rhs, opts)
		opts = opts or {}
		opts.buffer = bufnr
		opts.silent = opts.silent ~= false
		vim.keymap.set(mode, lhs, rhs, opts)
	end

	set("n", "<leader>cl", function()
		Snacks.picker.lsp_config()
	end, { desc = "Lsp Info" })

	if has(bufnr, "textDocument/definition") then
		set("n", "gd", function()
			Snacks.picker.lsp_definitions()
		end, { desc = "Goto Definition" })
	end

	if has(bufnr, "textDocument/declaration") then
		set("n", "gD", function()
			Snacks.picker.lsp_declarations()
		end, { desc = "Goto Declaration" })
	end

	if has(bufnr, "textDocument/references") then
		set("n", "gr", function()
			Snacks.picker.lsp_references()
		end, { nowait = true, desc = "References" })
	end

	if has(bufnr, "textDocument/implementation") then
		set("n", "gI", function()
			Snacks.picker.lsp_implementations()
		end, { desc = "Goto Implementation" })
	end

	if has(bufnr, "textDocument/typeDefinition") then
		set("n", "gy", function()
			Snacks.picker.lsp_type_definitions()
		end, { desc = "Goto T[y]pe Definition" })
	end

	if has(bufnr, "textDocument/hover") then
		set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
	end

	if has(bufnr, "textDocument/signatureHelp") then
		set("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
		set("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })
	end

	if has(bufnr, "textDocument/codeAction") then
		set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
		set("n", "<leader>cA", source_action("source"), { desc = "Source Action" })
		set("n", "<leader>co", source_action("source.organizeImports"), { desc = "Organize Imports" })
	end

	if has(bufnr, "textDocument/codeLens") then
		set({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, { desc = "Run Codelens" })
	end

	if has(bufnr, "textDocument/rename") then
		set("n", "<leader>cr", function()
			local inc_rename = require("inc_rename")
			return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
		end, { expr = true, desc = "Rename" })
	end

	if has(bufnr, "workspace/willRenameFiles") or has(bufnr, "workspace/didRenameFiles") then
		set("n", "<leader>cR", function()
			Snacks.rename.rename_file()
		end, { desc = "Rename File" })
	end

	if has(bufnr, "textDocument/incomingCalls") then
		set("n", "gai", function()
			Snacks.picker.lsp_incoming_calls()
		end, { desc = "C[a]lls Incoming" })
	end

	if has(bufnr, "textDocument/outgoingCalls") then
		set("n", "gao", function()
			Snacks.picker.lsp_outgoing_calls()
		end, { desc = "C[a]lls Outgoing" })
	end

	if has(bufnr, "textDocument/documentHighlight") then
		set("n", "]]", function()
			Snacks.words.jump(vim.v.count1)
		end, { desc = "Next Reference" })
		set("n", "[[", function()
			Snacks.words.jump(-vim.v.count1)
		end, { desc = "Prev Reference" })
	end
end

return M
