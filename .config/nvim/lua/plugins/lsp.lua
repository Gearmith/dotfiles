return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Language servers
        "intelephense",
        "typescript-language-server",
        "eslint-lsp",
        "css-lsp",
        "html-lsp",
        "lua-language-server",
        "tailwindcss-language-server",
        "json-lsp",
        "emmet-language-server",
        -- Formatters
        "prettierd",
        "stylua",
        "php-cs-fixer",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Tailwind CSS IntelliSense
        tailwindcss = {
          filetypes = {
            "html", "css", "scss", "javascript", "typescript",
            "javascriptreact", "typescriptreact", "php", "blade",
          },
        },
        -- JSON with schema support
        jsonls = {},
        -- Emmet abbreviation expansion
        emmet_language_server = {
          filetypes = {
            "html", "css", "scss", "javascript", "typescript",
            "javascriptreact", "typescriptreact", "php",
          },
        },
      },
    },
  },
}
