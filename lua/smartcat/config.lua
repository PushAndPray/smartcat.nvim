local M = {}

M.config = {
	split_direction = "vertical",
	split_size = 80,
	mappings = {
		ask = "<leader>ai",
		extend = "<leader>ae",
		list = "<leader>al",
	},
	spinner = {
		frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
		text = "Thinking...",
	},
}

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

function M.get()
	return M.config
end

return M
