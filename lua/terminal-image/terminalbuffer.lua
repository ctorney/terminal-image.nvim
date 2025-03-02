---@class terminal-image.terminalbuffer
---@field buf number
---@field imgs table<number, snacks.image.Placement>
---@field idx table<number, snacks.image.Placement>
local M = {}
M.__index = M
local uv = vim.uv or vim.loop
function M.new(buf)
	local self = setmetatable({}, M)
	self.buf = buf
	self.cursor_row = 0
	self.scan_line = 0
	self.imgs = {}
	self.idx = {}
	local group = vim.api.nvim_create_augroup("snacks.image.inline." .. buf, { clear = true })

	self.events = {}
	vim.api.nvim_buf_attach(buf, false, {
		on_lines = function(...)
			table.insert(self.events, { ... })
			vim.notify("Hello from on_lines", vim.log.levels.INFO)
		end,
	})

	local timer = assert(uv.new_timer())

	local update = function()
		return timer:start(
			1000,
			500,
			vim.schedule_wrap(function()
				self:update()
			end)
		)
	end

	vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		group = group,
		buffer = buf,
		callback = function(ev)
			vim.notify("Hello from close", vim.log.levels.INFO)
			if ev.buf == self.buf then
				timer:stop()
				vim.notify("Hello from timer stop", vim.log.levels.INFO)
			end
		end,
	})
	-- vim.schedule(update)
	return self
end

function M:update()
	vim.notify("Hello from image update", vim.log.levels.INFO)
	vim.notify(self.events, vim.log.levels.INFO)
	-- return
	-- get number of lines in the buffer
	local lines = vim.api.nvim_buf_line_count(self.buf)

	if self.scan_line < lines then
		-- loop through the lines
		for i = self.scan_line, lines do
			-- get the line
			local line = vim.api.nvim_buf_get_lines(self.buf, i, i + 1, false)[1]
			-- check if the line contains an image
			-- local img = line:match("![%[]")
			-- if img then
			--   -- get the image path
			--   local path = line:match("%((.+)%)")
			--   if path then
			--     -- create a new image
			--     local img = snacks.image.Placement.new(path, i, 0)
			--     -- add the image to the list
			--     table.insert(self.imgs, img)
			--     -- add the index to the list
			--     self.idx[i] = #self.imgs
			--   end
			-- end
			-- vim.notify("scanning line " .. i, vim.log.levels.INFO)
		end
		self.scan_line = lines
	end
	-- local win_id = vim.fn.bufwinid(self.buf)
	-- if win_id ~= -1 then
	-- get the current cursor position
	-- local cursor = vim.api.nvim_win_get_cursor(win_id)
	-- vim.notify("Hello from image update", vim.log.levels.INFO)
	-- vim.notify(cursor[1], vim.log.levels.INFO)
	--
	-- -- if the cursor is the same as the last time, do nothing
	-- if cursor[1] == self.cursor_row then
	-- 	return
	-- end
	--
	-- vim.notify("Hello from image update", vim.log.levels.INFO)
	-- self.cursor_row = cursor[1]
	-- end
end

return M
