return {
  -- Surround text with brackets, quotes, tags, etc.
  { "kylechui/nvim-surround", event = "VeryLazy", config = true },

  -- Highlight other occurrences of word under cursor
  { "RRethy/vim-illuminate", event = "VeryLazy" },

  -- ── Harpoon 2 — instant file teleportation ───────────────────────────────
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon"):setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
        },
      })
    end,
    keys = {
      {
        "<leader>ha",
        function() require("harpoon"):list():add() end,
        desc = "Harpoon: add file",
      },
      {
        "<leader>hh",
        function()
          local h = require("harpoon")
          h.ui:toggle_quick_menu(h:list())
        end,
        desc = "Harpoon: menu",
      },
      { "<leader>h1", function() require("harpoon"):list():select(1) end, desc = "Harpoon: file 1" },
      { "<leader>h2", function() require("harpoon"):list():select(2) end, desc = "Harpoon: file 2" },
      { "<leader>h3", function() require("harpoon"):list():select(3) end, desc = "Harpoon: file 3" },
      { "<leader>h4", function() require("harpoon"):list():select(4) end, desc = "Harpoon: file 4" },
      { "<leader>hp", function() require("harpoon"):list():prev() end, desc = "Harpoon: prev" },
      { "<leader>hn", function() require("harpoon"):list():next() end, desc = "Harpoon: next" },
    },
  },

  -- ── Undotree — visual undo history ───────────────────────────────────────
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
  },

  -- ── vim-visual-multi — multiple cursors ──────────────────────────────────
  -- Ctrl+D: select next occurrence (like VS Code)
  -- Ctrl+Alt+D: select all occurrences
  -- Alt+Up/Down: add cursor above/below
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-d>",
        ["Find Subword Under"] = "<C-d>",
        ["Select All"] = "<C-M-d>",
        ["Add Cursor Down"] = "<M-Down>",
        ["Add Cursor Up"] = "<M-Up>",
      }
    end,
  },

  -- ── vim-matchup — smarter % matching ─────────────────────────────────────
  -- Understands language constructs: if/elseif/else/endif, tags, etc.
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
}
