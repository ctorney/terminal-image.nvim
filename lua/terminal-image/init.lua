local M = {}

local terminalbuffer = require("terminal-image.terminalbuffer")
local augroup = vim.api.nvim_create_augroup("terminal-image", { clear = true })

function M.setup()
	vim.api.nvim_create_autocmd("TermOpen", {
		group = augroup,
		pattern = "*",
		callback = function(args)
			terminalbuffer.new(args.buf)
		end,
	})
end

return M
