local M = {}
local api = vim.api
local buffer_manager = require("smartcat.buffer_manager")
local config = require("smartcat.config")

-- Spinner implementation
local Spinner = {
	timer = nil,
	running = false,
}

function Spinner:start()
	if self.running then
		return
	end
	self.running = true
	self.timer = vim.uv.new_timer()
	local frame = 1

	self.timer:start(
		0,
		100,
		vim.schedule_wrap(function()
			if not self.running then
				return
			end
			vim.cmd(string.format('echo "%s %s"', config.get().spinner.frames[frame], config.get().spinner.text))
			frame = frame % #config.get().spinner.frames + 1
		end)
	)
end

function Spinner:stop()
	if not self.running then
		return
	end
	self.running = false
	if self.timer then
		self.timer:stop()
		self.timer:close()
		self.timer = nil
	end
	vim.schedule(function()
		vim.cmd("echo ''")
	end)
end

function M.list_responses()
	buffer_manager.cleanup_invalid_buffers()

	if #buffer_manager.buffers == 0 then
		vim.notify("No SmartCat responses available", vim.log.levels.INFO)
		return
	end

	local items = {}
	for _, bufnr in ipairs(buffer_manager.buffers) do
		if api.nvim_buf_is_valid(bufnr) then
			table.insert(items, {
				bufnr = bufnr,
				name = api.nvim_buf_get_name(bufnr),
			})
		end
	end

	vim.ui.select(items, {
		prompt = "Select SmartCat Response:",
		format_item = function(item)
			return item.name
		end,
	}, function(choice)
		if choice then
			api.nvim_set_current_buf(choice.bufnr)
		end
	end)
end

function M.handle_system_response(bufnr, response)
	if not response then
		return
	end

	if response.code ~= 0 then
		vim.schedule(function()
			vim.notify("SmartCat Error: " .. (response.stderr or "Unknown error"), vim.log.levels.ERROR)
		end)
		return
	end

	if response.stdout then
		vim.schedule(function()
			local lines = vim.split(vim.trim(response.stdout), "\n")
			buffer_manager.insert_lines(bufnr, lines)
		end)
	end
end

---@param bufnr number
---@param prompt string
---@param stdin? table
---@param args? table
function M.ask_smartcat(bufnr, prompt, stdin, args)
	-- check if the input starts with a template name
	local template_pattern = "^-[%a-_]+"
	local template = nil
	local input = prompt
	if string.find(prompt, template_pattern) ~= nil then
		local start_index, end_index = string.find(prompt, template_pattern)
		template = string.sub(prompt, start_index + 1, end_index)
		input = string.sub(prompt, end_index + 2)
	end
	local escaped_input = input:gsub('"', '\\"'):gsub("[$]", "\\$"):gsub("`", "\\`")
	local cmd = vim.iter({ "sc", args or {}, template or {}, '"' .. escaped_input .. '"' }):flatten():totable()

	Spinner:start()

	local success, result = pcall(function()
		return vim.system(
			cmd,
			{ text = true, stdin = stdin },
			vim.schedule_wrap(function(obj)
				Spinner:stop()
				M.handle_system_response(bufnr, obj)
			end)
		)
	end)

	if not success then
		Spinner:stop()
		vim.notify("SmartCat Error executing command: " .. tostring(result), vim.log.levels.ERROR)
	end
end

return M
