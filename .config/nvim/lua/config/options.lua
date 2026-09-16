-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Context when scrolling (LazyVim default is 4)
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Line number column width
vim.opt.numberwidth = 3

-- Always show sign column with fixed width
vim.opt.signcolumn = "yes:1"

-- Clean UI
vim.opt.winbar = ""
vim.opt.cmdheight = 1
vim.opt.showtabline = 0

-- Smooth scrolling (Neovim 0.10+)
vim.opt.smoothscroll = true

-- Spell in Spanish and English
vim.opt.spelllang = { "en", "es" }

-- Wrap long lines visually but don't break words
vim.opt.wrap = true
vim.opt.linebreak = true

-- Show invisible characters
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
