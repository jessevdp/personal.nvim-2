vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("plugin.open_help_in_vertical_split", { clear = true }),
  pattern = "help",
  command = "wincmd L",
})
