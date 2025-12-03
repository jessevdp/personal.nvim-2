vim.pack.add({
  { src = "https://github.com/stevearc/oil.nvim" },
}, { confirm = false })

local oil = require("oil")

oil.setup({
  default_file_explorer = true,
  skip_confirm_for_simple_edits = true,
  watch_for_changes = true,
})

vim.keymap.set("n", "-", "<cmd>Oil<CR>")
