vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
}, { confirm = false })

vim.lsp.enable({
  "jsonls",
  "lua_ls",
  "nixd",
  "ruby_lsp",
  "stylua",
})

vim.lsp.inlay_hint.enable()
