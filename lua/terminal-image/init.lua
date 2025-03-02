local terminalbuffer = require("terminal-image.terminalbuffer")

local function setup()
	-- Create autocommand group
	local augroup = vim.api.nvim_create_augroup("YaReplImage", { clear = true })

	vim.notify("Hello from image setup", vim.log.levels.INFO)
	vim.api.nvim_create_autocmd("TermOpen", {
		group = augroup,
		pattern = "*",
		callback = function(args)
			vim.notify("Hello from termopen", vim.log.levels.INFO)
			local bufnr = args.buf
			terminalbuffer.new(bufnr)
		end,
	})
end

return { setup = setup }
