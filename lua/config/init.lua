vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.updatetime = 500

vim.o.exrc = true
vim.o.secure = true

require("config.completion")
require("config.indentation")
require("config.mouse")
require("config.quickfix")
require("config.scroll")
require("config.search")
require("config.splits")
require("config.terminal")
require("config.ui")
require("config.undo")
require("config.wrapping")

require("config.treesitter")
require("config.lsp")

require("config.colorscheme")

require("config.notifications")
require("config.dropbar")
require("config.explorer")
require("config.picker")
