return {
  -- Gruvbox (classic dark, medium contrast) with a transparent background
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      contrast = "", -- "" = medium (default)
      transparent_mode = true,
      overrides = {
        NormalFloat = { bg = "NONE" },
        FloatBorder = { bg = "NONE" },
        SignColumn = { bg = "NONE" },
      },
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  -- Make LazyVim use Gruvbox instead of tokyonight
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "gruvbox" },
  },

  -- Disable catppuccin (bundled by LazyVim as an optional colorscheme)
  { "catppuccin/nvim", name = "catppuccin", enabled = false },

  -- Disable kanagawa
  {
    "rebelot/kanagawa.nvim",
    enabled = false,
  },
}
