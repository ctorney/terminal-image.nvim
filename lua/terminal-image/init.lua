local M = {}

local terminalbuffer = require("terminal-image.terminalbuffer")
local augroup = vim.api.nvim_create_augroup("terminal-image", { clear = true })

local default_opts = {
	max_num_images = 10,
	autoscroll = true,
}

function M.setup(user_opts)
	local opts = vim.tbl_deep_extend("force", default_opts, user_opts or {})
	vim.api.nvim_create_autocmd("TermOpen", {
		group = augroup,
		pattern = "term://*",
		callback = function(args)
			terminalbuffer.new(args.buf, opts)
		end,
	})
end

return M
