---@class terminal-image.terminalbuffer
---@field buf number
---@field imgs table<number, snacks.image.Placement>
---@field idx table<number, snacks.image.Placement>

local M = {}
M.__index = M

function M.new(buf)
	local self = setmetatable({}, M)
	self.buf = buf
	self.imgs = {}
	self.idx = {}
	-- local group = vim.api.nvim_create_augroup("snacks.image.inline." .. buf, { clear = true })

	vim.api.nvim_buf_attach(buf, true, {
		on_lines = function(bufnr, chan, changedtick, firstline, lastline, new_lastline, byte_count)
			self:update(firstline, lastline)
		end,
	})

	-- vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
	-- 	group = group,
	-- 	buffer = buf,
	-- 	callback = function(ev)
	-- 		vim.notify("Hello from close", vim.log.levels.INFO)
	-- 		if ev.buf == self.buf then
	-- 			timer:stop()
	-- 			vim.notify("Hello from timer stop", vim.log.levels.INFO)
	-- 		end
	-- 	end,
	-- })

	return self
end

function M:update(firstline, lastline)
	for i = firstline + 1, lastline do
		local line = vim.api.nvim_buf_get_lines(self.buf, i, i + 1, false)[1]
		if not line then
			break
		end
		-- check if the line contains an image
		local img = line:match("^hello")
		if img then
			local ns = vim.api.nvim_create_namespace("my_terminal_marks")
			vim.api.nvim_buf_set_extmark(self.buf, ns, i, 0, {
				virt_text = { { "bello", "Comment" } },
				virt_text_pos = "overlay",
				hl_mode = "combine",
				priority = 10,
			})
		end
	end
end

return M
