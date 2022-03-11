local l = require "local_defs"

vim.g.mapleader = ","

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
local t = require "telescope"
local tb = require "telescope.builtin"
local bd = require "betterdigraphs"

wk.register {
  ["<F1>"] = { "<cmd>Gitsigns stage_hunk<cr>", "stage hunk" },
  -- ["<F1>"] = { function () require "gitsigns".stage_hunk() end, "stage hunk" },
  ["<F2>"] = { "<cmd>Gitsigns prev_hunk<cr>", "previous hunk" },
  ["<F3>"] = { "<cmd>Gitsigns next_hunk<cr>", "next hunk" },
  ["<S-F1>"] = { "<cmd>q<cr>", "quit" },
  ["<S-F2>"] = { function() d.goto_prev() end, "previous diagnostic" },
  ["<S-F3>"] = { function() d.goto_next() end, "next diagnostic" },
  ["ö"] = { "<cmd>:wa<cr>", "write all" },
  g = {
    D = { function () lb.declaration() end, "declaration" },
    d = { function () lb.definition() end, "definition" },
    i = { function () lb.implementation() end, "implementation" },
    r = { function () lb.references() end, "references" },
    l = {
      name = "+lsp",
      a = { function () lb.code_action() end, "action" },
      D = { function () lb.type_definition() end, "type definition" },
      f = { function () lb.formatting() end, "format" },
      i = { function () lb.incoming_calls() end, "incoming calls" },
      K = { function () lb.hover() end, "hover" },
      k = { function () lb.signature_help() end, "signature" },
      l = { function () vim.diagnostic.open_float() end, "show" },
      o = { function () lb.outgoing_calls() end, "outgoing calls" },
      q = { function () vim.diagnostic.setqflist() end, "quickfix" },
      r = { function () lb.rename() end, "rename" },
      t = {
        name = "+toggle",
        s = { function () require("null-ls").toggle("codespell") end, "codespell" },
      },
      v = {
        name = "+virtual text",
        h = { function () d.hide() end, "hide" },
        s = { function () d.show() end, "show" },
      },
      w = {
        name = "+workspace",
        a = { function () lb.add_workspace_folder() end, "add" },
        l = { function () print(vim.inspect(lb.list_workspace_folders())) end, "list" },
        r = { function () lb.remove_workspace_folder() end, "remove" },
      },
      y = {
        name = "+tsserver",
        i = { ":TSLspImportAll<cr>", "import all" },
        o = { ":TSLspOrganize<cr>", "organise" },
        r = { ":TSLspRenameFile<cr>", "rename file" },
      },
    },
    t = {
      name = "+toggle",
      h = { ":TSBufToggle highlight<cr>", "treesitter highlight" },
    },
  },
  r = {
    name = "+replace",
    ["<F5>"] = { "r[", "[" },
    ["<F6>"] = { "r]", "]" },
    ["<F7>"] = { "r{", "{" },
    ["<F8>"] = { "r}", "}" },
    ["<F9>"] = { "r|", "|" },
    ["<F10>"] = { "r~", "~" },
    ["<C-k><C-k>"] = { function () bd.digraphs("r") end, "digraph" },
  },
  ["<leader>"] = {
    ["."] = { function () tb.find_files { hidden = true } end, "find files" },
    [" "] = { function () tb.oldfiles() end, "old files" },
    d = { "<cmd>MarkdownPreviewToggle<cr>", "markdown" },
    m = { function () tb.git_status() end, "git" },
    f = {
      name = "+telescope",
      a = { function () tb.lsp_code_actions() end, "lsp code actions" },
      b = { function () tb.buffers() end, "buffers" },
      d = { function () tb.lsp_definitions() end, "lsp definitions" },
      f = { function () tb.builtin() end, "builtin" },
      g = { function () tb.live_grep() end, "grep" },
      G = { function () tb.live_grep {
          additional_args = function() return { "-w" } end
        } end, "grep word" },
      h = { function () tb.help_tags() end, "help" },
      l = { function () tb.current_buffer_fuzzy_find() end, "fuzzy find" },
      p = { function () t.extensions.neoclip.default() end, "paste" },
      r = { function () tb.lsp_references() end, "lsp references" },
      R = { function () t.extensions.refactoring.refactors() end, "refactor" },
      s = { function () tb.grep_string() end, "grep string" },
      S = { function () tb.grep_string { word_match = "-w" } end, "grep string word" },
      t = { function () tb.tags() end, "tags" },
      T = { function () tb.tags { only_current_buffer = true } end, "local tags" },
    },
    g = {
      name = "+git",
      g = { "<cmd>tab Git commit<cr>", "commit" },
    },
    h = {
      name = "+hunk",
      b = { function () require "gitsigns".blame_line { full = true } end, "blame" },
      d = { "<cmd>Gitsigns diffthis<cr>", "diff hunk" },
      D = { function () require "gitsigns".diffthis("~") end, "diff" },
      p = { "<cmd>Gitsigns preview_hunk<cr>", "preview hunk" },
      R = { "<cmd>Gitsigns reset_buffer<cr>", "reset_buffer" },
      r = { "<cmd>Gitsigns reset_hunk<cr>", "reset hunk" },
      S = { "<cmd>Gitsigns stage_buffer<cr>", "stage buffer" },
      s = { "<cmd>Gitsigns stage_hunk<cr>", "stage hunk" },
      u = { "<cmd>Gitsigns undo_stage_hunk<cr>", "unstage hunk" },
    },
    q = {
      name = "+quote",
      q = { [[cs'"]], "single -> double", noremap = false },
      Q = { [[cs"']], "double -> single", noremap = false },
    },
    s = {
      name = "+spell",
      d = { "<cmd>setlocal spell spelllang=de_ch<cr>", "Deutsch" },
      e = { "<cmd>setlocal spell spelllang=en_gb<cr>", "English" },
      o = { "<cmd>set nospell<cr>", "off" },
    },
    t = {
      name = "+toggle",
      b = { "<cmd>Gitsigns toggle_current_line_blame<CR>", "blame" },
      d = { "<cmd>Gitsigns toggle_deleted<CR>", "deleted" },
      o = { "<cmd>SymbolsOutline<cr>", "symbols" },
      s = { function () require "sidebar-nvim".toggle() end, "sidebar" },
      t = { function () require "nvim-tree".toggle() end, "tree" },
    },
  },
}

wk.register({
  ["<F1>"] = { "<cmd>Gitsigns stage_hunk<cr>", "stage lines" },
  glf = { function () lb.range_formatting() end, "format" },
  ["r<C-k><C-k>"] = { "<esc><cmd>lua bd.digraphs('gvr')<cr>", "digraph" },
  ["<leader>"] = {
    h = {
      name = "+hunk",
      r = { "<cmd>Gitsigns reset_hunk<cr>", "reset lines" },
      s = { "<cmd>Gitsigns stage_hunk<cr>", "stage lines" },
      -- s = {'<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<cr>', "stage lines"},
    },
  },
}, {mode = "v"})

wk.register({
  ["<F5>"] = { "[", "[" },
  ["<F6>"] = { "]", "]" },
  ["<F7>"] = { "{", "{" },
  ["<F8>"] = { "}", "}" },
  ["<F9>"] = { "|", "|" },
  ["<F10>"] = { "~", "~" },
  ["<C-k><C-k>"] = { function () bd.digraphs("gvr") end, "digraph" },
}, {mode = "i"})

local vmap = vim.api.nvim_set_keymap -- global mappings
local m = l.map.defmap
local f4 = [[:execute "tjump /^\\(_build_\\)\\?" . expand("<cword>") . "$"<cr>]]

vmap("n", "<F4>",       f4,                                    m)
vmap("n", "<F6>",       ":cprevious<cr>",                      m)
vmap("n", "<S-F6>",     ":lprevious<cr>",                      m)
vmap("n", "<F7>",       ":cnext<cr>",                          m)
vmap("n", "<S-F7>",     ":lnext<cr>",                          m)
vmap("n", "<F9>",       "<cmd>cclose<bar>lclose<bar>only<cr>", m)
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

vmap("n", "ga",      "<Plug>(EasyAlign)", {})
vmap("x", "ga",      "<Plug>(EasyAlign)", {})
vmap("v", "<Enter>", "<Plug>(EasyAlign)", {})

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
