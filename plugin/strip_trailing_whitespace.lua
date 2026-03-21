vim.api.nvim_create_user_command("StripTrailingWhitespace", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
end, { desc = "Strip trailing whitespace from current buffer" })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("plugin.strip_trailing_whitespace", { clear = true }),
  callback = function()
    local ec = vim.b.editorconfig
    if ec and ec.trim_trailing_whitespace == "false" then
      return
    end
    vim.cmd("StripTrailingWhitespace")
  end,
})
