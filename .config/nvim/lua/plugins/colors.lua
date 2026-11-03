return {
  -- GitHub Dark with a transparent background
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    priority = 1000,
    lazy = false,
    opts = {
      options = {
        transparent = true,
      },
      groups = {
        github_dark = {
          NormalFloat = { bg = "NONE" },
          FloatBorder = { bg = "NONE" },
          SignColumn = { bg = "NONE" },
        },
      },
    },
    config = function(_, opts)
      require("github-theme").setup(opts)
      vim.cmd.colorscheme("github_dark")
    end,
  },

  -- Make LazyVim use GitHub Dark instead of tokyonight
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "github_dark" },
  },

  -- Disable catppuccin (bundled by LazyVim as an optional colorscheme)
  { "catppuccin/nvim", name = "catppuccin", enabled = false },

  -- Disable kanagawa
  {
    "rebelot/kanagawa.nvim",
    enabled = false,
  },
}
