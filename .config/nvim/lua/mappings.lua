G.mapleader = ","

Map("i", "<F5>",       "[",                                   Defmap)
Map("n", "r<F5>",      "r[",                                  Defmap)
Map("i", "<F6>",       "]",                                   Defmap)
Map("n", "r<F6>",      "r]",                                  Defmap)
Map("i", "<F7>",       "{",                                   Defmap)
Map("n", "r<F7>",      "r{",                                  Defmap)
Map("i", "<F8>",       "}",                                   Defmap)
Map("n", "r<F8>",      "r}",                                  Defmap)
Map("i", "<F9>",       "|",                                   Defmap)
Map("n", "r<F9>",      "r|",                                  Defmap)
Map("i", "<F10>",      "~",                                   Defmap)
Map("n", "r<F10>",     "r~",                                  Defmap)
Map("n", "<F9>",       "<cmd>cclose<bar>lclose<bar>only<cr>", Defmap)
Map("n", "<F12>",      "",                                  Defmap)
Map("n", "<PageUp>",   "0",                                 Defmap)
Map("n", "<PageDown>", "0",                                 Defmap)

Map("n", "<leader>.",  [[<cmd>lua require"telescope.builtin".find_files({ hidden = true })<cr>]], Defmap)
Map("n", "<leader> ",  [[<cmd>lua require"telescope.builtin".oldfiles()<cr>]],                    Defmap)
Map("n", "<leader>m",  [[<cmd>lua require"telescope.builtin".git_status()<cr>]],                  Defmap)
Map("n", "<leader>fb", [[<cmd>lua require"telescope.builtin".buffers()<cr>]],                     Defmap)
Map("n", "<leader>ff", [[<cmd>lua require"telescope.builtin".builtin()<cr>]],                     Defmap)
Map("n", "<leader>fg", [[<cmd>lua require"telescope.builtin".live_grep()<cr>]],                   Defmap)
Map("n", "<leader>fh", [[<cmd>lua require"telescope.builtin".help_tags()<cr>]],                   Defmap)
Map("n", "<leader>fs", [[<cmd>lua require"telescope.builtin".grep_string()<cr>]],                 Defmap)
Map("n", "<leader>fl", [[<cmd>lua require"telescope.builtin".current_buffer_fuzzy_find()<cr>]],   Defmap)

Map("n", "<leader>gg", [[<cmd>tab Git commit<cr>]], Defmap)

Map("n", "ga",      "<Plug>(EasyAlign)", {})
Map("x", "ga",      "<Plug>(EasyAlign)", {})
Map("v", "<Enter>", "<Plug>(EasyAlign)", {})

Map("n", "<leader>qq", [[cs'"]], {})
Map("n", "<leader>qQ", [[cs"']], {})

-- map("n", "<leader>l" [[<cmd>let @/ = ""<bar> :call UncolorAllWords()<cr>]], Defmap)

Cmd([[
  nnoremap <silent> <leader>l :let @/ = ""<bar> :call UncolorAllWords()<cr>
]])
