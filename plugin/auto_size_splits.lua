vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("plugin.auto_size_splits", { clear = true }),
  command = "wincmd =",
})
