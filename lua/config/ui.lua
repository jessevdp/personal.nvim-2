vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.pack.add({
  { src = "https://github.com/m4xshen/smartcolumn.nvim" },
}, { confirm = false })

require("smartcolumn").setup({
  colorcolumn = { 80, 120 },
  scope = "window",
  disabled_filetypes = {
    "checkhealth",
    "help",
    "markdown",
    "nvim-pack",
    "nvim-undotree",
    "text",
  },
})
