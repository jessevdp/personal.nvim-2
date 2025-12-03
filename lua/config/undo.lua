vim.opt.undofile = true

vim.cmd("packadd nvim.undotree")

local function toggle_undotree()
  require("undotree").open({
    title = "Undotree",
    command = "45vnew",
  })
end

vim.keymap.set("n", "<leader>u", toggle_undotree)
