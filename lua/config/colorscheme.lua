vim.pack.add({
  { src = "https://gitlab.com/motaz-shokry/gruvbox.nvim.git" },
}, { confirm = false })

require("gruvbox").setup({
  extend_background_behind_borders = true,
  highlight_groups = {
    -- TODO: upstream to gruvbox.nvim
    LspReferenceText = { link = "LspReferenceRead" },
    LspReferenceWrite = { link = "LspReferenceRead" },
  },
})

vim.cmd("colorscheme gruvbox")
