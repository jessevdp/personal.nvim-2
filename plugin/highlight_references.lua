local group = vim.api.nvim_create_augroup("plugin.highlight_references", { clear = true })

vim.api.nvim_create_autocmd("CursorHold", {
  group = group,
  desc = "Highlight references under cursor",
  callback = function()
    if vim.fn.mode() == "i" then return end

    local clients = vim.lsp.get_clients({ bufnr = 0 })
    local supports_highlight = false
    for _, client in ipairs(clients) do
      if client.server_capabilities.documentHighlightProvider then
        supports_highlight = true
        break
      end
    end

    if supports_highlight then
      vim.lsp.buf.document_highlight()
    end
  end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  group = group,
  desc = "Clear highlights when moving the cursor or entering insert mode",
  callback = function()
    vim.lsp.buf.clear_references()
  end,
})
