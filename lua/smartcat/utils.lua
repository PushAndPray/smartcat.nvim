local M = {}

function M.safe_execute(fn, ...)
	local status, result = pcall(fn, ...)
	if not status then
		vim.notify("SmartCat Error: " .. result, vim.log.levels.ERROR)
		return nil
	end
	return result
end

return M
