vim.pack.add({
  { src = "https://gitlab.com/motaz-shokry/gruvbox.nvim.git" },
}, { confirm = false })

require("gruvbox").setup({
  extend_background_behind_borders = true,
  highlight_groups = {
    LspReferenceRead = { bg = "bg2" },
    PreInsert = { fg = "gray" },
  },
})

vim.cmd("colorscheme gruvbox")
