local M = {}
local api = vim.api
local config = require("smartcat.config")

M.buffers = {}
M.current = nil

function M.add(bufnr)
	table.insert(M.buffers, bufnr)
	M.current = bufnr
end

function M.remove(bufnr)
	for i, v in ipairs(M.buffers) do
		if v == bufnr then
			table.remove(M.buffers, i)
			break
		end
	end
end

function M.is_response_buffer(bufnr)
	return vim.tbl_contains(M.buffers, bufnr)
end

function M.cleanup_invalid_buffers()
	for i = #M.buffers, 1, -1 do
		local bufnr = M.buffers[i]
		if not api.nvim_buf_is_valid(bufnr) then
			M.remove(bufnr)
		end
	end
end

function M.insert_lines(bufnr, lines)
	if api.nvim_buf_is_valid(bufnr) then
		api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
	end
end

---@param prompt string
---@return number bufnr
function M.create_response_buffer(prompt)
	local conf = config.get()
	local split_cmd = conf.split_direction == "vertical" and string.format("vnew | vert resize %d", conf.split_size)
		or string.format("new | resize %d", conf.split_size)

	vim.cmd(split_cmd)

	local bufnr = api.nvim_get_current_buf()

	-- Set buffer options
	vim.cmd([[
	  setlocal buftype=nofile
	  setlocal bufhidden=hide
	  setlocal filetype=markdown
	  setlocal noswapfile
	  setlocal wrap
	  setlocal linebreak
	  setlocal nofoldenable
	  setlocal conceallevel=0
	]])

	-- Set unique buffer name
	api.nvim_buf_set_name(bufnr, string.format("[SmartCat: %s %s]", prompt, vim.fn.strftime("%d/%m/%Y %T")))

	-- Initialize buffer with prompt header
	if prompt and prompt ~= "" then
		M.insert_lines(bufnr, {
			"# " .. prompt,
			"",
			"---",
			"",
		})
	end

	vim.cmd("normal! G")
	M.add(bufnr)
	return bufnr
end

return M
