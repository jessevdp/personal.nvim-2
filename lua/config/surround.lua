vim.pack.add({
  { src = "https://github.com/echasnovski/mini.nvim" },
}, { confirm = false })

require("mini.surround").setup({
  mappings = {
    add = "gsa",
    delete = "gsd",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
    replace = "gsr",
    update_n_lines = "gsn",
    suffix_last = "",
    suffix_next = "",
  },
})
