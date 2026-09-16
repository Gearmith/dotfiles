return {
  -- ── nvim-treesitter — syntax highlighting and more ───────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      ensure_installed = {
        -- Web stack
        "php", "blade", "html", "css", "scss",
        "javascript", "typescript", "tsx",
        "json", "jsonc", "graphql",
        -- Tooling & config
        "lua", "bash", "yaml", "toml",
        "dockerfile", "regex",
        -- Docs
        "markdown", "markdown_inline",
        "vim", "vimdoc",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      -- Ctrl+Space expands selection, Backspace shrinks
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
  },

  -- ── treesitter-context — current scope pinned at top of buffer ───────────
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      max_lines = 3,
      trim_scope = "outer",
      mode = "cursor",
    },
    keys = {
      {
        "<leader>uC",
        function() require("treesitter-context").toggle() end,
        desc = "Toggle treesitter context",
      },
    },
  },
}
