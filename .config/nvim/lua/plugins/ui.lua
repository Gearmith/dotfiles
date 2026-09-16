return {
  -- ── nvim-notify — better notifications ───────────────────────────────────
  {
    "rcarriga/nvim-notify",
    opts = {
      stages = "slide",
      timeout = 3000,
      render = "wrapped-compact",
      max_width = 60,
      icons = {
        ERROR = " ",
        WARN = " ",
        INFO = " ",
        DEBUG = " ",
        TRACE = "✎ ",
      },
    },
  },

  -- ── noice.nvim — UI overhaul for messages, cmdline, popupmenu ────────────
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
    },
  },
}
