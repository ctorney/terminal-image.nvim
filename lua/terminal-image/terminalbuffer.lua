---@class terminal-image.terminalbuffer
---@field buf number
---@field imgs table<number, snacks.image.Placement>
---@field extids table<number, number>
---@field imgheights table<number, number>

local M = {}
M.__index = M
local uv = vim.uv or vim.loop
local ns = vim.api.nvim_create_namespace("terminal-image.nvim")

M.disabled = false
function M.new(buf, opts)
	local self = setmetatable({}, M)
	self.buf = buf
	self.imgs = {}
	self.imgheights = {}
	self.extids = {}
	M.max_num_images = opts.max_num_images
	M.autoscroll = opts.autoscroll
	local group = vim.api.nvim_create_augroup("terminal-image.terminalbuffer." .. buf, { clear = true })

	vim.api.nvim_buf_attach(buf, true, {
		on_lines = function(_, _, _, firstline, _, new_lastline)
			self:add(firstline, new_lastline)
		end,
	})

	-- Create a timer that calls update every 5 seconds
	self.timer = uv.new_timer()
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

	vim.api.nvim_create_autocmd("WinScrolled", {
		group = group,
		buffer = buf,
		callback = function()
			vim.schedule(function()
				if self.imgs then
					for _, img in ipairs(self.imgs) do
						img:update()
					end
				end
			end)
		end,
	})
	return self
end

function M:update()
	-- delete old images if more than max_num_images
	local a = {}
	local n_images = 0
	for n in pairs(self.imgs) do
		table.insert(a, n)
		n_images = n_images + 1
	end
	table.sort(a)
	local n_remove = math.max(n_images - M.max_num_images, 0)
	for i = 1, n_remove do
		self.imgs[a[i]]:del()
		vim.api.nvim_buf_del_extmark(self.buf, ns, self.extids[a[i]])
		self.imgs[a[i]] = nil
		self.extids[a[i]] = nil
	end

	-- delete images if the line no longer contains an image
	for i, img in pairs(self.imgs) do
		local line = vim.api.nvim_buf_get_lines(self.buf, i - 1, i, true)[1]
		if not line or not line:match("^%!%[terminalimage%]") then
			img:del()
			vim.api.nvim_buf_del_extmark(self.buf, ns, self.extids[i])
			self.imgs[i] = nil
			self.extids[i] = nil
			self.imgheights[i] = nil
		end
	end
end

function M:scroll()
	-- scroll the buffer so that the last output is visible
	local winid = vim.fn.bufwinid(self.buf)
	-- only scroll if the buffer is not active
	if windid == vim.api.nvim_get_current_win() then
		return
	end
	local winheight = vim.fn.winheight(windid)
	local lastline = vim.api.nvim_buf_line_count(self.buf)
	-- this includes all lines so need to find first non empty line
	local linecount = 0
	local topline = 1
	local startcount = false

	if lastline > winheight then
		startcount = true
	end

	for i = lastline, math.max(1, lastline - winheight), -1 do
		if self.imgs[i] then
			linecount = linecount + self.imgheights[i]
		else
			if startcount then
				linecount = linecount + 1
			else
				local line = vim.api.nvim_buf_get_lines(self.buf, i - 1, i, true)[1]
				-- check if the line is not empty
				if line and line:match("%S") then
					startcount = true
					linecount = linecount + 1
				end
			end
		end
		if linecount > winheight then
			break
		end
		topline = i
	end

	vim.fn.winrestview({ topline = topline, lnum = winheight })
end

function M:add(firstline, new_lastline)
	local new_lines = vim.api.nvim_buf_get_lines(self.buf, firstline, new_lastline, true)
	for i, line in ipairs(new_lines) do
		local splitline = false
		local image_present = line:match("^%!%[terminalimage%]")
		local image_path = line:match("^%!%[terminalimage%]%((.+)%)")
		if image_present and not image_path then
			if new_lines[i + 1] then
				-- check if the next line is an image
				local combined_line = line .. new_lines[i + 1]
				image_path = combined_line:match("^%!%[terminalimage%]%((.+)%)")
				splitline = true
			end
		end
		-- there's an image associated with this line but no longer any filepath
		if self.imgs[firstline + i] and not image_path then
			self.imgs[firstline + i]:del()
		end
		-- there's no image associated with this line but there is a filepath
		if not self.imgs[firstline + i] and image_path then
			local pos = { firstline + i, 0 }
			img = Snacks.image.placement.new(self.buf, image_path, {
				pos = pos,
				inline = true,
				conceal = true,
				type = "terminal",
			})

			-- Access the height from the state
			local height = img:state().loc.height

			self.imgs[firstline + i] = img
			self.extids[firstline + i] = vim.api.nvim_buf_set_extmark(self.buf, ns, firstline + i - 1, 0, {
				virt_text = { { string.rep(" ", #line + 2) } }, -- add 2 for the icon
				virt_text_pos = "overlay",
				priority = 100,
			})
			if splitline then
				vim.api.nvim_buf_set_extmark(self.buf, ns, firstline + i, 0, {
					virt_text = { { string.rep(" ", #new_lines[i + 1] + 2) } }, -- add 2 for the icon
					virt_text_pos = "overlay",
					priority = 100,
				})
				height = height + 1
			end
			self.imgheights[firstline + i] = height
			if M.autoscroll then
				self:scroll()
			end
		end
	end
end

return M
