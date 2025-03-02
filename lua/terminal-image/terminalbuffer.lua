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
	self.scan_line = 1
	self.imgs = {}
	self.idx = {}
	-- local group = vim.api.nvim_create_augroup("snacks.image.inline." .. buf, { clear = true })

	-- self.events = {}
	-- vim.api.nvim_buf_attach(buf, false, {
	-- 	on_lines = function(...)
	-- 		table.insert(self.events, { ... })
	-- 		vim.notify("Hello from on_lines", vim.log.levels.INFO)
	-- 	end,
	-- })

	vim.api.nvim_buf_attach(buf, true, {
		on_lines = function(bufnr, chan, changedtick, firstline, lastline, new_lastline, byte_count)
			self:update(firstline, lastline, new_lastline, changedtick)
		end,
	})
	-- local timer = assert(uv.new_timer())

	-- local update = function()
	-- 	return timer:start(
	-- 		1000,
	-- 		500,
	-- 		vim.schedule_wrap(function()
	-- 			self:update()
	-- 		end)
	-- 	)
	-- end

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
	-- vim.schedule(update)
	return self
end

print(" hello from terminalbuffer")
function M:update(firstline, lastline, new_lastline, changedtick)
	-- vim.notify(
	-- 	"Hello " .. firstline .. " " .. lastline .. " " .. new_lastline .. " " .. changedtick,
	-- 	vim.log.levels.INFO
	-- )
	-- vim.notify("Hello from image update", vim.log.levels.INFO)
	-- vim.notify(self.events, vim.log.levels.INFO)
	-- return
	-- get number of lines in the buffer
	-- local lines = vim.api.nvim_buf_line_count(self.buf)

	-- loop through the lines
	for i = firstline + 1, lastline do
		-- get the line
		local line = vim.api.nvim_buf_get_lines(self.buf, i, i + 1, false)[1]
		if not line then
			break
		end
		-- check if the line contains an image
		local img = line:match("^hello")
		if img then
			-- line = line:gsub("hello", "world")
			local ns = vim.api.nvim_create_namespace("my_terminal_marks")
			vim.api.nvim_buf_set_extmark(self.buf, ns, i, 0, {
				virt_text = { { "bello", "Comment" } },
				virt_text_pos = "overlay",
				hl_mode = "combine",
				priority = 10,
			})
			-- vim.api.nvim_buf_set_lines(self.buf, i, i + 1, false, { line })
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
			-- vim.notify("found on  " .. i, vim.log.levels.INFO)
		end
		-- vim.notify("scanning line " .. i, vim.log.levels.INFO)
	end
	self.scan_line = firstline
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
