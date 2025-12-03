vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("plugin.highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
