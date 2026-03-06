vim.pack.add({
  { src = "https://github.com/dmtrKovalenko/fff.nvim" },
}, { confirm = false })

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(event)
    if event.data.spec.name == "fff.nvim" and event.data.kind == "update" then
      require("fff.download").download_or_build_binary()
    end
  end,
})

local download = require("fff.download")
if not vim.uv.fs_stat(download.get_binary_path()) then
  download.download_or_build_binary()
end

local fff = require("fff")

fff.setup({
  prompt = "> ",
  title = "Files",
  layout = {
    prompt_position = "top",
    preview_position = "right",
    flex = {
      wrap = "bottom",
    },
  },
  preview = {
    line_numbers = true,
  },
  keymaps = {
    close = { "<Esc>", "<C-c>" },
    cycle_grep_modes = "<C-space>",
  },
})

vim.keymap.set("n", "<leader><leader>", fff.find_files)
vim.keymap.set("n", "<leader>sf", fff.find_files)
vim.keymap.set("n", "<leader>sg", fff.live_grep)
