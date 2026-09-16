-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Blade filetype detection (must be before php, more specific)
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("blade_ft", { clear = true }),
  pattern = "*.blade.php",
  callback = function()
    vim.bo.filetype = "blade"
  end,
})

-- Remove trailing whitespace on save (skips markdown and diff where it's meaningful)
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  callback = function()
    local ignored = { markdown = true, diff = true, gitcommit = true }
    if ignored[vim.bo.filetype] then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Spell check in prose filetypes
autocmd("FileType", {
  group = augroup("prose_spell", { clear = true }),
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
  end,
})

-- Make PHP files use 4-space indentation (PSR standard)
autocmd("FileType", {
  group = augroup("php_indent", { clear = true }),
  pattern = "php",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})
