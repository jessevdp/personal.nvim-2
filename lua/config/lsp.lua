vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
}, { confirm = false })

vim.lsp.enable({
  "jsonls",
  "lua_ls",
  "nil_ls",
  "nixd",
  "ruby_lsp",
  "stylua",
})

vim.lsp.inlay_hint.enable()

vim.keymap.set("n", "<leader>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    vim.keymap.set("n", "gqB", function()
      vim.lsp.buf.format({ async = false })
    end)
  end,
})
