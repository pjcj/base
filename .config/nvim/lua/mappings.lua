G.mapleader = ","

Map("n", "<S-F1>",     ":q<cr>",                              Defmap)
Map("n", "<S-F2>",     ":ALEPreviousWrap<cr>",                Defmap)
Map("n", "<S-F3>",     ":ALENextWrap<cr>",                    Defmap)
Map("n", "<F4>",       [[:execute "tjump /^\\(_build_\\)\\?" . expand("<cword>") . "$"<cr>]], Defmap)
Map("i", "<F5>",       "[",                                   Defmap)
Map("n", "r<F5>",      "r[",                                  Defmap)
Map("n", "<F6>",       ":cprevious<cr>",                      Defmap)
Map("n", "<S-F6>",     ":lprevious<cr>",                      Defmap)
Map("i", "<F6>",       "]",                                   Defmap)
Map("n", "r<F6>",      "r]",                                  Defmap)
Map("n", "<F7>",       ":cnext<cr>",                          Defmap)
Map("n", "<S-F7>",     ":lnext<cr>",                          Defmap)
Map("i", "<F7>",       "{",                                   Defmap)
Map("n", "r<F7>",      "r{",                                  Defmap)
Map("i", "<F8>",       "}",                                   Defmap)
Map("n", "r<F8>",      "r}",                                  Defmap)
Map("n", "<F9>",       "<cmd>cclose<bar>lclose<bar>only<cr>", Defmap)
Map("i", "<F9>",       "|",                                   Defmap)
Map("n", "r<F9>",      "r|",                                  Defmap)
Map("i", "<F10>",      "~",                                   Defmap)
Map("n", "r<F10>",     "r~",                                  Defmap)
Map("n", "<F12>",      "",                                  Defmap)
Map("n", "<PageUp>",   "0",                                 Defmap)
Map("n", "<PageDown>", "0",                                 Defmap)

Map("n", "<F13>", "<S-F1>",  {})
Map("n", "<F14>", "<S-F2>",  {})
Map("n", "<F15>", "<S-F3>",  {})
Map("n", "<F16>", "<S-F4>",  {})
Map("n", "<F17>", "<S-F5>",  {})
Map("n", "<F18>", "<S-F6>",  {})
Map("n", "<F19>", "<S-F7>",  {})
Map("n", "<F20>", "<S-F8>",  {})
Map("n", "<F21>", "<S-F9>",  {})
Map("n", "<F22>", "<S-F10>", {})
Map("n", "<F23>", "<S-F11>", {})
Map("n", "<F24>", "<S-F12>", {})

Map("n", "<F25>", "<C-F1>",  {})
Map("n", "<F26>", "<C-F2>",  {})
Map("n", "<F27>", "<C-F3>",  {})
Map("n", "<F28>", "<C-F4>",  {})
Map("n", "<F29>", "<C-F5>",  {})
Map("n", "<F30>", "<C-F6>",  {})
Map("n", "<F31>", "<C-F7>",  {})
Map("n", "<F32>", "<C-F8>",  {})
Map("n", "<F33>", "<C-F9>",  {})
Map("n", "<F34>", "<C-F10>", {})
Map("n", "<F35>", "<C-F11>", {})
Map("n", "<F36>", "<C-F12>", {})

Map("n", "<F37>", "<M-F1>",  {})
-- not working with neovim
Map("n", "<F38>", "<M-F2>",  {})
Map("n", "<F39>", "<M-F3>",  {})
Map("n", "<F40>", "<M-F4>",  {})
Map("n", "<F41>", "<M-F5>",  {})
Map("n", "<F42>", "<M-F6>",  {})
Map("n", "<F43>", "<M-F7>",  {})
Map("n", "<F44>", "<M-F8>",  {})
Map("n", "<F45>", "<M-F9>",  {})
Map("n", "<F46>", "<M-F10>", {})
Map("n", "<F47>", "<M-F11>", {})
Map("n", "<F48>", "<M-F12>", {})

-- Map("n", "<cr>", "compe#confirm('<CR>')", {})

Map("n", "ö", [[<cmd>:w<cr>]], Defmap)

Map("n", "<leader>gg", [[<cmd>tab Git commit<cr>]], Defmap)

Map("n", "ga",      "<Plug>(EasyAlign)", {})
Map("x", "ga",      "<Plug>(EasyAlign)", {})
Map("v", "<Enter>", "<Plug>(EasyAlign)", {})

Map("n", "<leader>qq", [[cs'"]], {})
Map("n", "<leader>qQ", [[cs"']], {})

Map("n", "<leader>se", [[<cmd>setlocal spell spelllang=en_gb<cr>]], Defmap)
Map("n", "<leader>sd", [[<cmd>setlocal spell spelllang=de_ch<cr>]], Defmap)
Map("n", "<leader>so", [[<cmd>set nospell<cr>]],                    Defmap)

Map("i", "<Tab>",   "<Plug>(vsnip-expand-or-jump)", {})
Map("s", "<Tab>",   "<Plug>(vsnip-expand-or-jump)", {})
Map("i", "<S-Tab>", "<Plug>(vsnip-jump-prev)",      {})
Map("s", "<S-Tab>", "<Plug>(vsnip-jump-prev)",      {})

Map("n", "s", "s", Defmap)
Map("n", "S", "S", Defmap)
Map("n", ",,", "<Plug>Lightspeed_s", {})
Map("n", ";;", "<Plug>Lightspeed_S", {})

-- map("n", "<leader>l" [[<cmd>let @/ = ""<bar> :call UncolorAllWords()<cr>]], Defmap)

Cmd([[
  nnoremap <silent> <leader>l :let @/ = ""<bar> :call UncolorAllWords()<cr>
  cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

  inoremap <expr> <C-e> pumvisible() ? "\<C-y>\<C-e>" : "\<Esc>a\<C-e>"
  inoremap <expr> <C-y> pumvisible() ? "\<C-y>\<C-y>" : "\<C-y>"
]])
