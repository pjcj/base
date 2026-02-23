-- UI-related autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Yank highlight
augroup("yank_highlight", { clear = true })
autocmd("TextYankPost", {
  group = "yank_highlight",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "Cursor", timeout = 1000 })
  end,
})

-- Dim inactive splits and unfocussed panes
augroup("pane_focus_dim", { clear = true })
local c = require("local_defs").colour
vim.api.nvim_set_hl(0, "NormalNC", { bg = c.base06 })
local saved_normal = nil
local is_dimmed = false
autocmd("FocusLost", {
  group = "pane_focus_dim",
  pattern = "*",
  callback = function()
    if is_dimmed then return end
    saved_normal = vim.api.nvim_get_hl(0, { name = "Normal" })
    vim.api.nvim_set_hl(0, "Normal", { bg = c.base06 })
    is_dimmed = true
  end,
})
autocmd("FocusGained", {
  group = "pane_focus_dim",
  pattern = "*",
  callback = function()
    if saved_normal then vim.api.nvim_set_hl(0, "Normal", saved_normal) end
    is_dimmed = false
  end,
})
