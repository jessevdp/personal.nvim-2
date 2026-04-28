vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
}, { confirm = false })

local ts_swap = require("nvim-treesitter-textobjects.swap")

local swap_motions = {
  { "f", "@function.outer", "function def" },
  { "m", "@function.outer", "method def" },
  { "a", "@parameter.inner", "argument" },
}

for _, spec in ipairs(swap_motions) do
  local key, query, name = spec[1], spec[2], spec[3]
  local upper = key:upper()

  vim.keymap.set("n", "gm" .. key, function()
    ts_swap.swap_next(query)
  end, { desc = "Swap " .. name .. " forward" })
  vim.keymap.set("n", "gm" .. upper, function()
    ts_swap.swap_previous(query)
  end, { desc = "Swap " .. name .. " backward" })
end
