vim.schedule(function()
  -- work around ruby treesitter indentation weirdness
  -- see [https://github.com/nvim-treesitter/nvim-treesitter/issues/3363#issuecomment-1229157830]
  -- scheduled so it runs last
  vim.opt_local.indentkeys:remove(".")
end)
