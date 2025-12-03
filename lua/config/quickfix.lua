-- Center the current line when jumping through the quickfix list.
-- Extends `:h default-mappings`.
vim.keymap.set("n", "[q", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "[Q", "<cmd>cfirst<CR>zz")
vim.keymap.set("n", "]Q", "<cmd>clast<CR>zz")
vim.keymap.set("n", "[<C-q>", "<cmd>cpfile<CR>zz")
vim.keymap.set("n", "]<C-q>", "<cmd>cnfile<CR>zz")
