vim.pack.add({
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
}, { confirm = false })

require("gitsigns").setup({
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 500,
  },
  attach_to_untracked = true,

  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- Hunk navigation
    map("n", "]h", function()
      gs.nav_hunk("next")
    end, "Next hunk")
    map("n", "[h", function()
      gs.nav_hunk("prev")
    end, "Prev hunk")
    map("n", "]H", function()
      gs.nav_hunk("last")
    end, "Last hunk")
    map("n", "[H", function()
      gs.nav_hunk("first")
    end, "First hunk")

    -- Hunk actions
    map("n", "<leader>gs", gs.stage_hunk, "Stage/unstage git hunk")
    map("v", "<leader>gs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Stage selected lines")
    map("n", "<leader>gS", gs.stage_buffer, "Stage all hunks in buffer")
    map("n", "<leader>gU", gs.reset_buffer_index, "Unstage all hunks in buffer")
    map("n", "<leader>ghr", gs.reset_hunk, "Reset git hunk")
    map("v", "<leader>ghr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Reset selected lines")
    map("n", "<leader>ghp", gs.preview_hunk, "Preview git hunk")

    -- Blame
    map("n", "<leader>gb", function()
      gs.blame_line({ full = true })
    end, "Blame line")
    map("n", "<leader>gB", gs.blame, "Blame file")

    -- Hunk textobject
    map({ "o", "x" }, "ih", gs.select_hunk, "inner git hunk")
    map({ "o", "x" }, "ah", gs.select_hunk, "around git hunk")
  end,
})
