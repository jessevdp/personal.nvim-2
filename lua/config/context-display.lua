vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
}, { confirm = false })

require("treesitter-context").setup({
  separator = "─",
})

vim.keymap.set("n", "<leader>tc", function()
  require("treesitter-context").toggle()
end, { desc = "Toggle treesitter context" })
vim.keymap.set("n", "[c", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { desc = "Jump to context" })
