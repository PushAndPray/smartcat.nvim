---@class SmartCatConfig
---@field split_direction "vertical"|"horizontal"
---@field split_size number
---@field mappings table<string, string>
---@field spinner table

local M = {}
local api = vim.api
local fn = vim.fn

-- Import modules
local config = require("smartcat.config")
local buffer_manager = require("smartcat.buffer_manager")
local ui = require("smartcat.ui")
local utils = require("smartcat.utils")

-- Initialize the plugin
function M.setup(user_config)
	config.setup(user_config)
	M.setup_keymaps()
end

-- Setup keybindings
function M.setup_keymaps()
	-- List Response Buffers (Normal Mode)
	vim.keymap.set("n", config.get().mappings.list, ui.list_responses, {
		noremap = true,
		desc = "List SmartCat buffers",
	})

	-- New Question (Normal Mode)
	vim.keymap.set("n", config.get().mappings.ask, function()
		utils.safe_execute(function()
			local prompt = fn.input({ prompt = "Prompt: ", cancelreturn = nil })
			if not prompt or prompt == "" then
				return
			end

			local bufnr = buffer_manager.create_response_buffer(prompt)
			ui.ask_smartcat(bufnr, prompt)
		end)
	end, { noremap = true, desc = "Ask SmartCat a new question" })

	-- Context-Aware Question (Visual Mode)
	vim.keymap.set("v", config.get().mappings.ask, function()
		utils.safe_execute(function()
			local prompt = fn.input({ prompt = "Prompt: ", cancelreturn = "_cancelreturn" })
			if prompt == "_cancelreturn" then
				return
			end

			local file_type = vim.bo.filetype
			vim.cmd("normal! y")

			local bufnr = buffer_manager.create_response_buffer(prompt)
			local lines = vim.split(fn.getreg('"'), "\n")

			-- Format selected text with syntax highlighting
			table.insert(lines, 1, "```" .. file_type)
			table.insert(lines, #lines + 1, "```")
			buffer_manager.insert_lines(bufnr, lines)
			vim.cmd("normal! G")

			ui.ask_smartcat(bufnr, prompt .. "\n", lines)
		end)
	end, { noremap = true, desc = "Ask SmartCat about selected text" })

	-- Extend Conversation (Normal Mode)
	vim.keymap.set("n", config.get().mappings.extend, function()
		utils.safe_execute(function()
			local bufnr = api.nvim_get_current_buf()
			if not buffer_manager.is_response_buffer(bufnr) then
				vim.notify("Cannot extend conversation in this buffer", vim.log.levels.WARN)
				return
			end

			local prompt = fn.input({ prompt = "Extend prompt: ", cancelreturn = nil })
			if not prompt or prompt == "" then
				return
			end

			buffer_manager.insert_lines(bufnr, {
				"",
				"# " .. prompt,
				"",
				"---",
				"",
			})
			vim.cmd("normal! G")

			ui.ask_smartcat(bufnr, prompt, nil, { "-e" })
		end)
	end, { noremap = true, desc = "Extend conversation with SmartCat" })

	-- Extend Conversation (Visual Mode)
	vim.keymap.set("v", config.get().mappings.extend, function()
		utils.safe_execute(function()
			local bufnr = api.nvim_get_current_buf()
			if not buffer_manager.is_response_buffer(bufnr) then
				vim.notify("Cannot extend conversation in this buffer", vim.log.levels.WARN)
				return
			end

			local prompt = fn.input({ prompt = "Prompt: ", cancelreturn = "_cancelreturn" })
			if prompt == "_cancelreturn" then
				return
			end

			vim.cmd("normal! y")

			local lines = vim.split(fn.getreg('"'), "\n")

			vim.cmd("normal! G")

			ui.ask_smartcat(bufnr, prompt .. "\n", lines, { "-e" })
		end)
	end, { noremap = true, desc = "Extend conversation with SmartCat" })
end

return M
