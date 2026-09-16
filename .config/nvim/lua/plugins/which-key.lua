return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>h",  group = "harpoon",  icon = "󰛢 " },
        { "<leader>q",  group = "quickfix" },
        { "<leader>va", desc = "Select all" },
        { "<leader>bx", desc = "Close other buffers" },
        { "<leader>Z",  desc = "Zen mode" },
        { "<leader>D",  desc = "Delete to void" },
        { "<leader>P",  desc = "Paste from clipboard" },
        { "<leader>Y",  desc = "Yank line to clipboard" },
        { "<leader>uu", desc = "Toggle Undotree" },
        { "<leader>uC", desc = "Toggle treesitter context" },
        { "<leader>gd", desc = "Diffview open" },
        { "<leader>gD", desc = "Diffview close" },
        { "<leader>gl", desc = "File git log" },
        { "<leader>gL", desc = "Branch git log" },
      },
    },
  },
}
