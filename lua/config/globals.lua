local set = vim.opt

set.tabstop = 2
set.shiftwidth = 2
set.expandtab = true

set.updatetime = 200

set.undofile = true

set.number = true
set.relativenumber = true
set.signcolumn = 'yes'

set.cursorline = true

set.list = true
set.listchars = { tab = "» ", trail = "·", nbsp = "␣", }

set.mouse = 'a'

set.ignorecase = true
set.smartcase = true

set.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

set.inccommand = "split"

set.linebreak = true
set.breakindent = true
set.breakindentopt = "list:2"

set.scrolloff = 8
set.sidescrolloff = 8

set.splitbelow = true
set.splitright = true
