local l = require "local_defs"

local vmap = vim.api.nvim_set_keymap               -- global mappings

vim.g.mapleader = ","

vmap("n", "<S-F1>",     ":q<cr>",                              l.map.defmap)
vmap("n", "<S-F2>",     ":ALEPreviousWrap<cr>",                l.map.defmap)
vmap("n", "<S-F3>",     ":ALENextWrap<cr>",                    l.map.defmap)
vmap("n", "<F4>",       [[:execute "tjump /^\\(_build_\\)\\?" . expand("<cword>") . "$"<cr>]], l.map.defmap)
vmap("i", "<F5>",       "[",                                   l.map.defmap)
vmap("n", "r<F5>",      "r[",                                  l.map.defmap)
vmap("n", "<F6>",       ":cprevious<cr>",                      l.map.defmap)
vmap("n", "<S-F6>",     ":lprevious<cr>",                      l.map.defmap)
vmap("i", "<F6>",       "]",                                   l.map.defmap)
vmap("n", "r<F6>",      "r]",                                  l.map.defmap)
vmap("n", "<F7>",       ":cnext<cr>",                          l.map.defmap)
vmap("n", "<S-F7>",     ":lnext<cr>",                          l.map.defmap)
vmap("i", "<F7>",       "{",                                   l.map.defmap)
vmap("n", "r<F7>",      "r{",                                  l.map.defmap)
vmap("i", "<F8>",       "}",                                   l.map.defmap)
vmap("n", "r<F8>",      "r}",                                  l.map.defmap)
vmap("n", "<F9>",       "<cmd>cclose<bar>lclose<bar>only<cr>", l.map.defmap)
vmap("i", "<F9>",       "|",                                   l.map.defmap)
vmap("n", "r<F9>",      "r|",                                  l.map.defmap)
vmap("i", "<F10>",      "~",                                   l.map.defmap)
vmap("n", "r<F10>",     "r~",                                  l.map.defmap)
vmap("n", "<F12>",      "",                                  l.map.defmap)
vmap("n", "<PageUp>",   "0",                                 l.map.defmap)
vmap("n", "<PageDown>", "0",                                 l.map.defmap)

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

-- vmap("n", "<cr>", "compe#confirm('<CR>')", {})

vmap("n", "ö", [[<cmd>:w<cr>]], l.map.defmap)

vmap("n", "<leader>gg", [[<cmd>tab Git commit<cr>]], l.map.defmap)

vmap("n", "ga",      "<Plug>(EasyAlign)", {})
vmap("x", "ga",      "<Plug>(EasyAlign)", {})
vmap("v", "<Enter>", "<Plug>(EasyAlign)", {})

vmap("n", "<leader>qq", [[cs'"]], {})
vmap("n", "<leader>qQ", [[cs"']], {})

vmap("n", "<leader>se", [[<cmd>setlocal spell spelllang=en_gb<cr>]], l.map.defmap)
vmap("n", "<leader>sd", [[<cmd>setlocal spell spelllang=de_ch<cr>]], l.map.defmap)
vmap("n", "<leader>so", [[<cmd>set nospell<cr>]],                    l.map.defmap)

vmap("n", "s", "s", l.map.defmap)
vmap("n", "S", "S", l.map.defmap)
vmap("n", ",,", "<Plug>Lightspeed_s", {})
vmap("n", ";;", "<Plug>Lightspeed_S", {})

-- map("n", "<leader>l" [[<cmd>let @/ = ""<bar> :call UncolorAllWords()<cr>]], l.map.defmap)

vim.cmd([[
  nnoremap <silent> <leader>l :let @/ = ""<bar> :call UncolorAllWords()<cr>
  nnoremap <leader>W :%s/\s\+$//<cr>:let @/ = ""<cr>
  cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

  inoremap <expr> <C-e> pumvisible() ? "\<C-y>\<C-e>" : "\<Esc>a\<C-e>"
  inoremap <expr> <C-y> pumvisible() ? "\<C-y>\<C-y>" : "\<C-y>"
]])
