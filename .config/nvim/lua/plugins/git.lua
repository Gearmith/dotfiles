return {
  -- ── Gitsigns — inline git decorations ────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
        virt_text_pos = "eol",
      },
      current_line_blame_formatter = "<author>, <author_time:%d/%m/%y> · <summary>",
    },
  },

  -- ── Diffview — beautiful side-by-side diffs and git history ─────────────
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diffview: open" },
      { "<leader>gD", "<cmd>DiffviewClose<CR>", desc = "Diffview: close" },
      { "<leader>gl", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: file log" },
      { "<leader>gL", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview: branch log" },
    },
  },
}
