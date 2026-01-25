vim.pack.add({
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/malewicz1337/oil-git.nvim" },
}, { confirm = false })

require("oil").setup({
  default_file_explorer = true,
  skip_confirm_for_simple_edits = true,
  watch_for_changes = true,
})

require("oil-git").setup({})

vim.keymap.set("n", "-", "<cmd>Oil<CR>")

