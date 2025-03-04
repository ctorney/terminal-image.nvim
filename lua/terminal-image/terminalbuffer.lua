---@class terminal-image.terminalbuffer
---@field buf number
---@field imgs table<number, snacks.image.Placement>
---@field extids table<number, number>

local M = {}
M.__index = M

local ns = vim.api.nvim_create_namespace("terminal-image.nvim")

M.disabled = false
function M.new(buf)
	local self = setmetatable({}, M)
	self.buf = buf
	self.imgs = {}
	self.extids = {}
	local group = vim.api.nvim_create_augroup("terminal-image.terminalbuffer." .. buf, { clear = true })

	-- vim.api.nvim_buf_attach(buf, true, {
	-- 	on_lines = function(bufnr, chan, changedtick, firstline, lastline, new_lastline, byte_count)
	-- 		self:add(firstline, lastline)
	-- 	end,
	-- })

	vim.api.nvim_buf_attach(buf, true, {
		on_lines = function(_, _, _, firstline, _, new_lastline)
			self:add2(firstline, new_lastline)
		end,
	})

	-- Create a timer that calls update every 5 seconds
	self.timer = vim.loop.new_timer()
	self.timer:start(
		0,
		5000,
		vim.schedule_wrap(function()
			self:update()
		end)
	)

	-- Create an autocommand to stop the timer when the buffer is closed
	vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
		group = group,
		buffer = buf,
		callback = function()
			if self.timer then
				self.timer:stop()
				self.timer:close()
				self.timer = nil
			end
		end,
	})

	-- local update = Snacks.util.debounce(function()
	-- 	self:update()
	-- end, { ms = 100 })
	-- vim.api.nvim_create_autocmd("WinScrolled", {
	-- 	group = group,
	-- 	buffer = buf,
	-- 	callback = vim.schedule_wrap(update),
	-- })

	-- vim.api.nvim_create_autocmd("TermRequest", {
	-- 	group = group,
	-- 	buffer = buf,
	-- 	callback = vim.schedule_wrap(update),
	-- })

	return self
end

function M:update()
	for i, img in pairs(self.imgs) do
		vim.notify("i: " .. i)
		local line = vim.api.nvim_buf_get_lines(self.buf, i - 1, i, true)[1]
		if not line or not line:match("^%!%[terminalimage%]%((.+)%)") then
			img:del()
			vim.api.nvim_buf_del_extmark(self.buf, ns, self.extids[i])
			self.imgs[i] = nil
			self.extids[i] = nil
		end
	end
end

function M.disable()
	if M.disabled then
		M.disabled = false
		return
	end
	M.disabled = true
end

function M:add2(firstline, new_lastline)
	local new_lines = vim.api.nvim_buf_get_lines(self.buf, firstline, new_lastline, true)
	for i, line in ipairs(new_lines) do
		-- vim.notify("line: " .. line)
		local image_path = line:match("^%!%[terminalimage%]%((.+)%)")
		-- there's an image associated with this line but no longer any filepath
		if self.imgs[firstline + i] and not image_path then
			self.imgs[firstline + i]:del()
		end
		-- there's no image associated with this line but there is an filepath
		if not self.imgs[firstline + i] and image_path then
			local pos = { firstline + i, 0 }
			img = Snacks.image.placement.new(self.buf, image_path, {
				pos = pos,
				inline = true,
				conceal = true,
				type = "terminal",
			})
			self.imgs[firstline + i] = img
			self.extids[firstline + i] = vim.api.nvim_buf_set_extmark(self.buf, ns, firstline + i - 1, 0, {
				virt_text = { { string.rep(" ", #line + 2) } }, -- add 2 for the icon
				virt_text_pos = "overlay",
				priority = 100,
			})
			-- vim.api.nvim_buf_set_extmark(self.buf, ns, i, 0, {
			-- 	virt_text = { { string.rep(" ", #line + 2) } }, -- add 2 for the icon
			-- 	virt_text_pos = "overlay",
			-- 	priority = 100,
			-- })
		end

		-- if line:match("^%!%[terminalimage%]") then
		--   if image_path then
		--     local pos = { firstline + i, 0 }
		--     img = Snacks.image.placement.new(buf, image_path, {
		--       pos = pos,
		--       inline = true,
		--       conceal = true,
		--       type = "terminal",
		--     })
		--     self.imgs[firstline + i] = img
		--   end
		-- end
	end
end

function M:add(firstline, lastline)
	vim.notify("firstline: " .. firstline .. " lastline: " .. lastline)
	if M.disabled then
		return
	end
	for i = firstline, lastline do
		if not self.imgs[i] then
			local line = vim.api.nvim_buf_get_lines(self.buf, i, i + 1, false)[1]
			if line and line:match("^%!%[terminalimage%]") then
				local image_path = line:match("^%!%[terminalimage%]%((.+)%)")
				if image_path then
					local pos = { i + 1, 0 }
					img = Snacks.image.placement.new(self.buf, image_path, {
						pos = pos,
						inline = true,
						conceal = true,
						type = "terminal",
					})
					self.imgs[i] = img
					-- vim.api.nvim_buf_set_extmark(self.buf, ns, i, 0, {
					-- 	virt_text = { { string.rep(" ", #line + 2) } }, -- add 2 for the icon
					-- 	virt_text_pos = "overlay",
					-- 	priority = 100,
					-- })
				end
			end
		end
	end
end

return M
