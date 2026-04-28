vim.pack.add({
  { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
}, { confirm = false })

local hooks = require("ibl.hooks")
hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)

require("ibl").setup({
  indent = { char = "▏" },
  scope = {
    show_start = false,
    show_end = false,
  },
})
