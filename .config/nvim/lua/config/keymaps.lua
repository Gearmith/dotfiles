-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ── Escape ─────────────────────────────────────────────────────────────────
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- ── Save ────────────────────────────────────────────────────────────────────
map({ "n", "i", "x" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save file" })

-- ── Splits ──────────────────────────────────────────────────────────────────
map("n", "ss", ":split<CR>", { silent = true, desc = "Split horizontal" })
map("n", "sv", ":vsplit<CR>", { silent = true, desc = "Split vertical" })

-- Resize splits with arrows
map("n", "<C-Up>", ":resize +2<CR>", { silent = true, desc = "Increase window height" })
map("n", "<C-Down>", ":resize -2<CR>", { silent = true, desc = "Decrease window height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { silent = true, desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true, desc = "Increase window width" })

-- ── File explorer ────────────────────────────────────────────────────────────
map("n", "<leader>nn", function()
  Snacks.explorer()
end, { desc = "Toggle + Focus Explorer" })

-- ── Line movement ────────────────────────────────────────────────────────────
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-1<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ── Search ───────────────────────────────────────────────────────────────────
map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- ── Clipboard ────────────────────────────────────────────────────────────────
-- Explicit yank/paste to system clipboard (useful when clipboard=unnamedplus is off)
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>P", '"+p', { desc = "Paste from system clipboard" })

-- Don't overwrite clipboard when pasting over a selection
map("x", "p", '"_dP', { desc = "Paste without overwriting clipboard" })

-- Delete to void register (keeps clipboard clean)
map({ "n", "v" }, "<leader>D", '"_d', { desc = "Delete to void register" })

-- ── Selection ────────────────────────────────────────────────────────────────
map("n", "<leader>va", "ggVG", { desc = "Select all" })

-- ── Buffers ──────────────────────────────────────────────────────────────────
-- Close all buffers except current
map("n", "<leader>bx", ":%bd|e#|bd#<CR>", { silent = true, desc = "Close other buffers" })

-- ── Quickfix ─────────────────────────────────────────────────────────────────
map("n", "<leader>qn", ":cnext<CR>", { silent = true, desc = "Next quickfix item" })
map("n", "<leader>qp", ":cprev<CR>", { silent = true, desc = "Prev quickfix item" })
map("n", "<leader>qo", ":copen<CR>", { silent = true, desc = "Open quickfix list" })
map("n", "<leader>qc", ":cclose<CR>", { silent = true, desc = "Close quickfix list" })

-- ── Undo ─────────────────────────────────────────────────────────────────────
map("n", "<leader>uu", "<cmd>UndotreeToggle<CR>", { desc = "Toggle Undotree" })

-- ── Zen mode ────────────────────────────────────────────────────────────────
map("n", "<leader>Z", function()
  Snacks.zen()
end, { desc = "Toggle Zen Mode" })

-- ── Config ───────────────────────────────────────────────────────────────────
map("n", "<leader>rs", "<cmd>source $MYVIMRC<CR>", { desc = "Reload Neovim config" })
