vim.pack.add({
  { src = "https://github.com/spacedentist/resolve.nvim" },
}, { confirm = false })

vim.api.nvim_create_user_command("ListGitConflicts", function()
  local result = vim.system({ "git", "jump", "--stdout", "merge" }, { text = true }):wait()
  if result.code ~= 0 or result.stdout == "" then
    vim.notify("No merge conflicts found", vim.log.levels.INFO)
    return
  end
  local lines = vim.split(result.stdout, "\n", { trimempty = true })
  local items = vim.fn.getqflist({ lines = lines }).items
  vim.fn.setqflist({}, "r", { title = "Merge Conflicts", items = items })
  vim.notify(#items .. " merge conflicts found", vim.log.levels.INFO)
end, { desc = "Load all project conflict hunks into quickfix" })

local function add_conflict_labels(bufnr)
  local ns = vim.api.nvim_create_namespace("conflict_labels")
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    local label, hl
    if line:match("^<<<<<<<") then
      label, hl = "ours ↓", "ResolveOursMarkerHint"
    elseif line:match("^|||||||") then
      label, hl = "base ↓", "ResolveAncestorMarkerHint"
    elseif line:match("^>>>>>>>") then
      label, hl = "theirs ↑", "ResolveTheirsMarkerHint"
    end
    if label then
      vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
        virt_text = { { label, hl } },
        virt_text_pos = "eol",
      })
    end
  end
end

require("resolve").setup({
  default_keymaps = false,

  on_conflict_detected = function(info)
    add_conflict_labels(info.bufnr)

    local map = function(lhs, plug, desc)
      vim.keymap.set("n", lhs, plug, { buffer = info.bufnr, desc = desc })
    end

    map("<leader>gco", "<Plug>(resolve-ours)", "Conflict: choose ours")
    map("<leader>gct", "<Plug>(resolve-theirs)", "Conflict: choose theirs")
    map("<leader>gcb", "<Plug>(resolve-both)", "Conflict: choose both")
    map("<leader>gcB", "<Plug>(resolve-both-reverse)", "Conflict: choose both (reversed)")
    map("<leader>gca", "<Plug>(resolve-base)", "Conflict: choose ancestor/base")
    map("<leader>gcn", "<Plug>(resolve-none)", "Conflict: choose none")

    map("<leader>gcdo", "<Plug>(resolve-diff-ours)", "Conflict diff: base → ours")
    map("<leader>gcdt", "<Plug>(resolve-diff-theirs)", "Conflict diff: base → theirs")
    map("<leader>gcdb", "<Plug>(resolve-diff-both)", "Conflict diff: both")
    map("<leader>gcdv", "<Plug>(resolve-diff-vs)", "Conflict diff: ours → theirs")
    map("<leader>gcdV", "<Plug>(resolve-diff-vs-reverse)", "Conflict diff: theirs → ours")
  end,

  on_conflicts_resolved = function(info)
    local keys = {
      "<leader>gco",
      "<leader>gct",
      "<leader>gcb",
      "<leader>gcB",
      "<leader>gca",
      "<leader>gcn",
      "<leader>gcdo",
      "<leader>gcdt",
      "<leader>gcdb",
      "<leader>gcdv",
      "<leader>gcdV",
    }
    for _, lhs in ipairs(keys) do
      pcall(vim.keymap.del, "n", lhs, { buffer = info.bufnr })
    end
  end,
})
