return {
  -- Switch to Catppuccin Mocha — best plugin integration coverage
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled = true,
        shade = "dark",
        percentage = 0.12,
      },
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        keywords = { "italic" },
        functions = {},
        variables = {},
        strings = {},
      },
      integrations = {
        blink_cmp = true,
        bufferline = true,
        diffview = true,
        flash = true,
        gitsigns = true,
        harpoon = true,
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mason = true,
        mini = { enabled = true },
        noice = true,
        notify = true,
        snacks = true,
        telescope = { enabled = true },
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Disable kanagawa
  {
    "rebelot/kanagawa.nvim",
    enabled = false,
  },
}
