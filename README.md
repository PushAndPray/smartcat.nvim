# smartcat.nvim

A Neovim plugin for [efugier/smartcat](https://github.com/efugier/smartcat)

## ✨ Features

- Ask questions and get AI responses directly within Neovim
- Context-aware queries using visual selection
- Extend existing conversations
- Easy navigation between response buffers
- Markdown formatting for responses
- Configurable split behavior and keymaps

## 📦 Installation

1. Install the smartcat CLI tool (follow instructions at [efugier/smartcat](https://github.com/efugier/smartcat))
2. Install the plugin using your favorite package manager:

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
   "bytesoverflow/smartcat.nvim",
   opts = {}
},
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use 'bytesoverflow/smartcat.nvim'
```

3. Setup the plugin in your `init.lua` (not needed with lazy.nvim if `opts` is set):

```lua
require("smartcat").setup()
```

## 🚀 Usage

Default keybindings:

- `<Leader>ai` (normal mode) Ask a new question
- `<Leader>ai` (visual mode) Ask about selected text
- `<Leader>ae` (in response buffer) Extend the current conversation
- `<Leader>al` List and navigate between response buffers

### Examples

1. Ask a general question:
   - Press `<Leader>ai`
   - Type your question
   - Response appears in a new split

2. Ask about code:
   - Select code in visual mode
   - Press `<Leader>ai`
   - Type your question
   - Response appears in a new split

3. Continue a conversation:
   - In a response buffer, press `<Leader>ae`
   - Type your follow-up
   - Response appears in the same buffer

### Templates

Starting the input with `-template question text` will use that template from the smartcat config.

## 🔧 Configuration

You can pass your config table into the `setup()` function or `opts` if you use lazy.nvim.

```lua
require("smartcat").setup({
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
})
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

[MIT License](LICENSE)
