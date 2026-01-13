vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>+", "<cmd>let @+=@0<CR>", { desc = "Copy last yank to system clipboard" })
