local M = {}

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Enable all configured language servers",
  once = true,
  callback = function()
    local server_names = M.get_all_server_names()
    vim.lsp.enable(server_names)
  end,
})

M.get_all_server_names = function()
  local names = {}

  for name, _ in pairs(vim.lsp.config) do
    if name ~= "*" and name ~= "_configs" then
      names[name] = true
    end
  end

  for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
    local base = vim.fs.basename(path) -- e.g. "lua_ls.lua"
    local name = base:sub(1, #base - 4) -- "lua_ls"
    names[name] = true
  end

  return vim.tbl_keys(names)
end
