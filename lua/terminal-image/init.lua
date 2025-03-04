local M = {}

local terminalbuffer = require("terminal-image.terminalbuffer")
local augroup = vim.api.nvim_create_augroup("terminal-image", { clear = true })

function M.setup()
	vim.api.nvim_create_autocmd("TermOpen", {
		group = augroup,
		pattern = "term://*",
		callback = function(args)
			terminalbuffer.new(args.buf)
		end,
	})
	vim.api.nvim_set_keymap(
		"t",
		"<C-q>",
		"<cmd>lua require('terminal-image.terminalbuffer').disable()<CR>",
		{ noremap = true, silent = true }
	)
end

return M
