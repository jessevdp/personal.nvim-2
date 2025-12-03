local group = vim.api.nvim_create_augroup("plugin.cursorline_follows_focus", { clear = true })

vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained", "WinEnter" }, {
  group = group,
  callback = function()
    vim.wo.cursorline = true
  end,
})

vim.api.nvim_create_autocmd({ "FocusLost", "WinLeave" }, {
  group = group,
  callback = function()
    vim.wo.cursorline = false
  end,
})
