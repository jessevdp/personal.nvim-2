vim.pack.add({
  { src = "https://github.com/Bekaboo/dropbar.nvim" },
}, { confirm = false })

require("dropbar").setup({
  bar = {
    enable = function(buf, win, _)
      buf = vim._resolve_bufnr(buf)
      if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
        return false
      end

      if
        not vim.api.nvim_buf_is_valid(buf)
        or not vim.api.nvim_win_is_valid(win)
        or vim.fn.win_gettype(win) ~= ""
        or vim.wo[win].winbar ~= ""
        or vim.bo[buf].ft == "help"
      then
        return false
      end

      local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
      if stat and stat.size > 1024 * 1024 then
        return false
      end

      return vim.bo[buf].ft == "markdown"
        or vim.bo[buf].ft == "oil"
        or pcall(vim.treesitter.get_parser, buf)
        or not vim.tbl_isempty(vim.lsp.get_clients({
          bufnr = buf,
          method = "textDocument/documentSymbol",
        }))
    end,
  },
  sources = {
    path = {
      relative_to = function(buf, win)
        local ok, cwd = pcall(vim.fn.getcwd, win)
        local base = ok and cwd or vim.fn.getcwd()
        if vim.bo[buf].ft == "oil" then
          local dir = require("oil").get_current_dir(buf)
          if dir and vim.fn.fnamemodify(dir, ":p") == vim.fn.fnamemodify(base, ":p") then
            return vim.fn.fnamemodify(base, ":h")
          end
        end
        return base
      end,
    },
    terminal = {
      show_current = false,
    },
  },
})
