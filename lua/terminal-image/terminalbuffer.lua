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
	local group = vim.api.nvim_create_augroup("terminal-image.terminalbuffer." .. buf, { clear = true })

	vim.api.nvim_buf_attach(buf, true, {
		on_lines = function(bufnr, chan, changedtick, firstline, lastline, new_lastline, byte_count)
			self:add(firstline, lastline)
		end,
	})

	local update = Snacks.util.debounce(function()
		self:update()
	end, { ms = 100 })

	vim.api.nvim_create_autocmd("WinScrolled", {
		group = group,
		buffer = buf,
		callback = vim.schedule_wrap(update),
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

function M:update()
	for _, img in pairs(self.imgs) do
		img:update()
	end
end

function M:add(firstline, lastline)
	local ns = vim.api.nvim_create_namespace("terminal-image.nvim")
	for i = firstline + 1, lastline do
		if not self.imgs[i] then
			local line = vim.api.nvim_buf_get_lines(self.buf, i, i + 1, false)[1]
			if line and line:match("^%!%[terminalimage%]") then
				-- Extract image path
				local image_path = line:match("^%!%[terminalimage%]%((.+)%)")
				local pos = { i + 1, 0 }
				img = Snacks.image.placement.new(self.buf, image_path, {
					pos = pos,
					inline = true,
					conceal = true,
					type = "terminal",
				})
				self.imgs[i] = img
				vim.api.nvim_buf_set_extmark(self.buf, ns, i, 0, {
					virt_text = { { string.rep(" ", #line) } }, -- Virtual text matching the exact line length
					virt_text_pos = "overlay",
					priority = 100,
				})
			end
		end
	end
end

return M
