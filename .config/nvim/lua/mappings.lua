local l = require "local_defs"

local wk = require "which-key"
-- {
--   mode = "n", -- NORMAL mode
--   prefix = "",
--   buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
--   silent = true, -- use `silent` when creating keymaps
--   noremap = true, -- use `noremap` when creating keymaps
--   nowait = false, -- use `nowait` when creating keymaps
-- }

local lb = vim.lsp.buf
local d = vim.diagnostic
wk.register {
  ["<S-F1>"] = { ":q\n", "quit" },
  ["<S-F2>"] = { function() d.goto_prev() end, "previous diagnostic" },
  ["<S-F3>"] = { function() d.goto_next() end, "next diagnostic" },
  ["g"] = {
    D = { function () lb.declaration() end, "declaration" },
    d = { function () lb.definition() end, "definition" },
    i = { function () lb.implementation() end, "implementation" },
    r = { function () lb.references() end, "references" },
    l = {
      name = "+lsp",
      K = { function () lb.hover() end, "hover" },
      k = { function () lb.signature_help() end, "signature" },
      D = { function () lb.type_definition() end, "type definition" },
      l = { function () vim.diagnostic.open_float() end, "show" },
      r = { function () lb.rename() end, "rename" },
      a = { function () lb.code_action() end, "action" },
      i = { function () lb.incoming_calls() end, "incoming calls" },
      o = { function () lb.outgoing_calls() end, "outgoing calls" },
      q = { function () vim.diagnostic.setqflist() end, "quickfix" },
      f = { function () lb.formatting() end, "format",  },
      v = {
        name = "+virtual text",
        h = { function () d.hide() end, "hide" },
        s = { function () d.show() end, "show" },
      },
      w = {
        name = "+workspace",
        a = { function () lb.add_workspace_folder() end, "add" },
        r = { function () lb.remove_workspace_folder() end, "remove" },
        l = { function () print(vim.inspect(lb.list_workspace_folders())) end, "list" },
      },
    },
    lf = { function () lb.range_formatting() end, "format", mode = "v" },
    ["<leader>"] = {
      t = {
        name = "+toggle",
        o = { "<cmd>SymbolsOutline<cr>", "Show Symbols" },
      },
    },
  }
}

local vmap = vim.api.nvim_set_keymap               -- global mappings

vim.g.mapleader = ","

local m = l.map.defmap
local f4 = [[:execute "tjump /^\\(_build_\\)\\?" . expand("<cword>") . "$"<cr>]]

vmap("n", "<F4>",       f4,                                    m)
vmap("i", "<F5>",       "[",                                   m)
vmap("n", "r<F5>",      "r[",                                  m)
vmap("n", "<F6>",       ":cprevious<cr>",                      m)
vmap("n", "<S-F6>",     ":lprevious<cr>",                      m)
vmap("i", "<F6>",       "]",                                   m)
vmap("n", "r<F6>",      "r]",                                  m)
vmap("n", "<F7>",       ":cnext<cr>",                          m)
vmap("n", "<S-F7>",     ":lnext<cr>",                          m)
vmap("i", "<F7>",       "{",                                   m)
vmap("n", "r<F7>",      "r{",                                  m)
vmap("i", "<F8>",       "}",                                   m)
vmap("n", "r<F8>",      "r}",                                  m)
vmap("n", "<F9>",       "<cmd>cclose<bar>lclose<bar>only<cr>", m)
vmap("i", "<F9>",       "|",                                   m)
vmap("n", "r<F9>",      "r|",                                  m)
vmap("i", "<F10>",      "~",                                   m)
vmap("n", "r<F10>",     "r~",                                  m)
vmap("n", "<F12>",      "",                                  m)
vmap("n", "<PageUp>",   "0",                                 m)
vmap("n", "<PageDown>", "0",                                 m)

vmap("n", "<F13>", "<S-F1>",  {})
vmap("n", "<F14>", "<S-F2>",  {})
vmap("n", "<F15>", "<S-F3>",  {})
vmap("n", "<F16>", "<S-F4>",  {})
vmap("n", "<F17>", "<S-F5>",  {})
vmap("n", "<F18>", "<S-F6>",  {})
vmap("n", "<F19>", "<S-F7>",  {})
vmap("n", "<F20>", "<S-F8>",  {})
vmap("n", "<F21>", "<S-F9>",  {})
vmap("n", "<F22>", "<S-F10>", {})
vmap("n", "<F23>", "<S-F11>", {})
vmap("n", "<F24>", "<S-F12>", {})

vmap("n", "<F25>", "<C-F1>",  {})
vmap("n", "<F26>", "<C-F2>",  {})
vmap("n", "<F27>", "<C-F3>",  {})
vmap("n", "<F28>", "<C-F4>",  {})
vmap("n", "<F29>", "<C-F5>",  {})
vmap("n", "<F30>", "<C-F6>",  {})
vmap("n", "<F31>", "<C-F7>",  {})
vmap("n", "<F32>", "<C-F8>",  {})
vmap("n", "<F33>", "<C-F9>",  {})
vmap("n", "<F34>", "<C-F10>", {})
vmap("n", "<F35>", "<C-F11>", {})
vmap("n", "<F36>", "<C-F12>", {})

vmap("n", "<F37>", "<M-F1>",  {})
-- not working with neovim
vmap("n", "<F38>", "<M-F2>",  {})
vmap("n", "<F39>", "<M-F3>",  {})
vmap("n", "<F40>", "<M-F4>",  {})
vmap("n", "<F41>", "<M-F5>",  {})
vmap("n", "<F42>", "<M-F6>",  {})
vmap("n", "<F43>", "<M-F7>",  {})
vmap("n", "<F44>", "<M-F8>",  {})
vmap("n", "<F45>", "<M-F9>",  {})
vmap("n", "<F46>", "<M-F10>", {})
vmap("n", "<F47>", "<M-F11>", {})
vmap("n", "<F48>", "<M-F12>", {})

vmap("n", "ö", [[<cmd>:w<cr>]], m)

vmap("n", "<leader>gg", [[<cmd>tab Git commit<cr>]], m)

vmap("n", "ga",      "<Plug>(EasyAlign)", {})
vmap("x", "ga",      "<Plug>(EasyAlign)", {})
vmap("v", "<Enter>", "<Plug>(EasyAlign)", {})

vmap("n", "<leader>qq", [[cs'"]], {})
vmap("n", "<leader>qQ", [[cs"']], {})

vmap("n", "<leader>se", [[<cmd>setlocal spell spelllang=en_gb<cr>]], m)
vmap("n", "<leader>sd", [[<cmd>setlocal spell spelllang=de_ch<cr>]], m)
vmap("n", "<leader>so", [[<cmd>set nospell<cr>]],                    m)

vmap("n", "s", "s", m)
vmap("n", "S", "S", m)
vmap("n", ",,", "<Plug>Lightspeed_s", {})
vmap("n", ";;", "<Plug>Lightspeed_S", {})

-- map("n", "<leader>l" [[<cmd>let @/ = ""<bar> :call UncolorAllWords()<cr>]], m)

vim.cmd [[
  nnoremap <silent> <leader>l :let @/ = ""<bar> :call UncolorAllWords()<cr>
  nnoremap <leader>W :%s/\s\+$//<cr>:let @/ = ""<cr>
  cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

  inoremap <expr> <C-e> pumvisible() ? "\<C-y>\<C-e>" : "\<Esc>a\<C-e>"
  inoremap <expr> <C-y> pumvisible() ? "\<C-y>\<C-y>" : "\<C-y>"
]]
