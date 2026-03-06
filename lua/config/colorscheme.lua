vim.pack.add({
  { src = "https://gitlab.com/motaz-shokry/gruvbox.nvim.git" },
}, { confirm = false })

require("gruvbox").setup({
  extend_background_behind_borders = true,
  highlight_groups = {
    -- TODO: upstream to gruvbox.nvim
    LspReferenceText = { link = "LspReferenceRead" },
    LspReferenceWrite = { link = "LspReferenceRead" },

    -- fff.nvim: selection
    FFFSelected = { fg = "orange_lite" },
    FFFSelectedActive = { fg = "orange_lite" },

    -- fff.nvim: git text
    FFFGitStaged = { link = "GitSignsAdd" },
    FFFGitModified = { link = "GitSignsChange" },
    FFFGitDeleted = { link = "GitSignsDelete" },
    FFFGitRenamed = { fg = "purple_lite" },
    FFFGitUntracked = { fg = "aqua_lite" },
    FFFGitIgnored = { fg = "gray" },

    -- fff.nvim: git signs
    FFFGitSignStaged = { link = "GitSignsAdd" },
    FFFGitSignModified = { link = "GitSignsChange" },
    FFFGitSignDeleted = { link = "GitSignsDelete" },
    FFFGitSignRenamed = { fg = "purple_lite" },
    FFFGitSignUntracked = { fg = "aqua_lite" },
    FFFGitSignIgnored = { fg = "gray" },

    -- fff.nvim: git signs (selected)
    FFFGitSignStagedSelected = { link = "GitSignsAdd" },
    FFFGitSignModifiedSelected = { link = "GitSignsChange" },
    FFFGitSignDeletedSelected = { link = "GitSignsDelete" },
    FFFGitSignRenamedSelected = { fg = "purple_lite" },
    FFFGitSignUntrackedSelected = { fg = "aqua_lite" },
    FFFGitSignIgnoredSelected = { fg = "gray" },
  },
})

vim.cmd("colorscheme gruvbox")
