return {
  -- Dracula with a transparent background
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      transparent_bg = true,
      italic_comment = true,
      show_end_of_buffer = false,
      overrides = {
        NormalFloat = { bg = "NONE" },
        FloatBorder = { bg = "NONE" },
      },
    },
    config = function(_, opts)
      require("dracula").setup(opts)
      vim.cmd.colorscheme("dracula")
    end,
  },

  -- Make LazyVim use Dracula instead of tokyonight
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "dracula" },
  },

  -- Disable catppuccin (bundled by LazyVim as an optional colorscheme)
  { "catppuccin/nvim", name = "catppuccin", enabled = false },

  -- Disable kanagawa
  {
    "rebelot/kanagawa.nvim",
    enabled = false,
  },
}
