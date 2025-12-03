vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.updatetime = 500

require("config.indentation")
require("config.mouse")
require("config.quickfix")
require("config.scroll")
require("config.search")
require("config.splits")
require("config.terminal")
require("config.undo")
require("config.wrapping")

require("config.treesitter")
require("config.lsp")

require("config.explorer")
