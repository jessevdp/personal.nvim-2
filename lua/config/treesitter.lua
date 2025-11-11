vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
}, { confirm = false })

local ts = require("nvim-treesitter")
ts.setup()

local autocmd_group = vim.api.nvim_create_augroup("config.treesitter", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = autocmd_group,
  pattern = { "*" },
  callback = function(event)
    local filetype = event.match
    local lang = vim.treesitter.language.get_lang(filetype)
    local is_installed = vim.treesitter.language.add(lang or filetype)

    if not is_installed then
      local is_available = vim.tbl_contains(ts.get_available(), lang)
      if not is_available then
        return
      end

      vim.notify("Installing treesitter parser for " .. lang, vim.log.levels.INFO)
      local ok = ts.install({ lang }):wait(30 * 1000)
      if not ok then
        vim.notify(
          "Unable to install treesitter parser for " .. lang .. ". See :checkhealth nvim-treesitter.",
          vim.log.levels.WARN
        )
        return
      end
    end

    vim.treesitter.start(event.buf, lang)

    vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})

vim.api.nvim_create_autocmd("PackChanged", {
  group = autocmd_group,
  pattern = { "nvim-treesitter" },
  callback = function()
    vim.notify("Updating treesitter parsers", vim.log.levels.INFO)
    vim.cmd("TSUpdate")
  end,
})
