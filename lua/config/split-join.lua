vim.pack.add({
  { src = "https://github.com/Wansmer/treesj" },
}, { confirm = false })

require("treesj").setup({
  use_default_keymaps = false,
  max_join_length = 200,
})

local tsj = require("treesj")

vim.keymap.set("n", "<leader>ns", tsj.split, { desc = "Split node" })
vim.keymap.set("n", "<leader>nS", function()
  tsj.split({ split = { recursive = true } })
end, { desc = "Split NODE (recursive)" })
vim.keymap.set("n", "<leader>nj", tsj.join, { desc = "Join node" })
vim.keymap.set("n", "<leader>nJ", function()
  tsj.join({ join = { recursive = true } })
end, { desc = "Join NODE (recursive)" })
