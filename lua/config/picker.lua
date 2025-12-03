vim.pack.add({
  { src = "https://github.com/ibhagwan/fzf-lua" },
}, { confirm = false })

local fzf = require("fzf-lua")

fzf.setup({
  { "borderless-full" },
})

vim.keymap.set("n", "<leader><leader>", fzf.buffers)
vim.keymap.set("n", "<leader>sf", fzf.git_files)
vim.keymap.set("n", "<leader>sg", fzf.live_grep)
vim.keymap.set("n", "<leader>sb", fzf.buffers)
vim.keymap.set("n", "<leader>sh", fzf.helptags)
vim.keymap.set("n", "<leader>s.", fzf.resume)
