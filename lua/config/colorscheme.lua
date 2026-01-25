vim.pack.add({
  { src = "https://gitlab.com/motaz-shokry/gruvbox.nvim.git" },
}, { confirm = false })

require("gruvbox").setup({
  extend_background_behind_borders = true,
  highlight_groups = {
    LspReferenceRead = { bg = "bg2" },
    PreInsert = { fg = "gray" },

    OilGitAdded = { fg = "green_dark" },
    OilGitModified = { fg = "yellow_dark" },
    OilGitRenamed = { fg = "blue_dark" },
    OilGitDeleted = { fg = "red_dark" },
    OilGitCopied = { fg = "blue_dark" },
    OilGitConflict = { fg = "purple_dark" },
    OilGitUntracked = { fg = "bg2" },
    OilGitIgnored = { fg = "gray" },
  },
})

vim.cmd("colorscheme gruvbox")
