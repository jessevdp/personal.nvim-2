vim.pack.add({
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
}, { confirm = false })

require("mini.extra").setup()

local ai = require("mini.ai")
local extra = require("mini.extra")
-- gen_spec.treesitter() throws when no parser or query exists for the
-- buffer's language. Wrap it so missing queries degrade silently.
local function ts(captures)
  local spec = ai.gen_spec.treesitter(captures)
  return function(...)
    local ok, result = pcall(spec, ...)
    if ok then
      return result
    end
  end
end

ai.setup({
  custom_textobjects = {
    -- Treesitter
    F = ts({ a = "@function.outer", i = "@function.inner" }),
    M = ts({ a = "@function.outer", i = "@function.inner" }),
    f = ts({ a = "@call.outer", i = "@call.inner" }),
    m = ts({ a = "@call.outer", i = "@call.inner" }),
    c = ts({ a = "@class.outer", i = "@class.inner" }),
    o = ts({ a = "@block.outer", i = "@block.inner" }),
    a = ts({ a = "@parameter.outer", i = "@parameter.inner" }),

    -- Custom
    B = extra.gen_ai_spec.buffer(),
    i = extra.gen_ai_spec.indent(),
  },

  -- Disable next/last variants — they clash with Neovim 0.12's built-in
  -- treesitter incremental selection (:h v_an, :h v_in).
  mappings = {
    around_next = "",
    inside_next = "",
    around_last = "",
    inside_last = "",
  },
})

-------------------------------------------------------------------------------
-- Bracket motions via nvim-treesitter-textobjects move module.
-------------------------------------------------------------------------------

require("nvim-treesitter-textobjects").setup({
  move = { set_jumps = true },
})

local ts_move = require("nvim-treesitter-textobjects.move")

local function goto_next(query)
  return function()
    ts_move.goto_next_start(query, "textobjects")
  end
end

local function goto_prev(query)
  return function()
    ts_move.goto_previous_start(query, "textobjects")
  end
end

local function goto_first(query)
  return function()
    vim.fn.setpos("''", vim.fn.getpos("."))
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    ts_move.goto_next_start(query, "textobjects")
  end
end

local function goto_last(query)
  return function()
    vim.fn.setpos("''", vim.fn.getpos("."))
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(0), 0 })
    ts_move.goto_previous_start(query, "textobjects")
  end
end

local bracket_motions = {
  { "f", "@function.outer", "function def" },
  { "m", "@function.outer", "method def" },
  { "a", "@parameter.outer", "argument" },
  { "o", "@block.outer", "block" },
}

for _, spec in ipairs(bracket_motions) do
  local key, query, name = spec[1], spec[2], spec[3]
  local upper = key:upper()
  local modes = { "n", "x", "o" }

  vim.keymap.set(modes, "]" .. key, goto_next(query), { desc = "Next " .. name })
  vim.keymap.set(modes, "[" .. key, goto_prev(query), { desc = "Prev " .. name })
  vim.keymap.set(modes, "]" .. upper, goto_last(query), { desc = "Last " .. name })
  vim.keymap.set(modes, "[" .. upper, goto_first(query), { desc = "First " .. name })
end
