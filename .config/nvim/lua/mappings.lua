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
local bd = require "better-digraphs"
local gs = require "gitsigns"

local async = require("plenary.async")
local packer_sync = function()
  async.run(function()
    vim.notify.async("Syncing packer.", "info", { title = "Packer" })
  end)
  local snap_shot_time = os.date("!%Y-%m-%dT%TZ")
  vim.cmd("PackerSnapshot " .. snap_shot_time)
  vim.cmd("PackerSync")
end

wk.register {
  ["<F1>"] = { gs.stage_hunk, "stage hunk" },
  ["<F2>"] = { gs.prev_hunk, "stage hunk" },
  ["<F3>"] = { gs.next_hunk, "stage hunk" },
  ["<S-F1>"] = { ":q<cr>", "quit" },
  ["<S-F2>"] = { d.goto_prev, "previous diagnostic" },
  ["<S-F3>"] = { d.goto_next, "next diagnostic" },
  ["<C-F2>"] = { "<Plug>(ale_previous_wrap)", "previous diagnostic" },
  ["<C-F3>"] = { "<Plug>(ale_next_wrap)", "next diagnostic" },
  ["<F4>"] = { [[:execute "tjump /^\\(_build_\\)\\?" . expand("<cword>") . "$"<cr>]], "jump to tag" },
  ["<F6>"] = { ":cprevious<cr>", "quickfix next" },
  ["<S-F6>"] = { ":lprevious<cr>", "location next" },
  ["<F7>"] = { ":cnext<cr>", "quickfix previous" },
  ["<S-F7>"] = { ":lnext<cr>", "location next" },
  ["<F9>"] = { ":cclose<bar>lclose<bar>only<cr>", "close other windows" },
  ["<F12>"] = { "", "previous buffer" },
  ["<Tab>"] = { "expand selection" },
  ["<PageUp>"] = { "0", "page up" },
  ["<PageDown>"] = { "0", "page down" },
  ["<C-L>"] = { "refresh" },
  ["-"] = { "comment" },
  ["ä"] = { "show cursor" },
  ["ö"] = { ":w<cr> | :wa<cr>", "write all" },

  ["n"] = { [[<cmd>execute("normal! " . v:count1 . "n")<cr><cmd>lua require("hlslens").start()<cr>]], "next match" },
  ["N"] = { [[<cmd>execute("normal! " . v:count1 . "N")<cr><cmd>lua require("hlslens").start()<cr>]], "next match" },
  ["*"] = { [[*<cmd>lua require("hlslens").start()<cr>]], "next word" },
  ["#"] = { [[#<cmd>lua require("hlslens").start()<cr>]], "prev word" },
  ["g*"] = { [[g*<cmd>lua require("hlslens").start()<cr>]], "next word part" },
  ["g#"] = { [[g#<cmd>lua require("hlslens").start()<cr>]], "prev word part" },

  g = {
    name = "+goto",
    D = { lb.declaration, "declaration" },
    d = { lb.definition, "definition" },
    i = { lb.implementation, "implementation" },
    r = { lb.references, "references" },
    l = {
      name = "+lsp",
      a = { lb.code_action, "action" },
      D = { lb.type_definition, "type definition" },
      f = { lb.formatting, "format" },
      i = { lb.incoming_calls, "incoming calls" },
      K = { lb.hover, "hover" },
      k = { lb.signature_help, "signature" },
      l = { vim.diagnostic.open_float, "show" },
      o = { lb.outgoing_calls, "outgoing calls" },
      q = { vim.diagnostic.setqflist, "quickfix" },
      r = { lb.rename, "rename" },
      t = {
        name = "+toggle",
        s = { function() require("null-ls").toggle("codespell") end, "codespell" },
      },
      v = {
        name = "+virtual text",
        h = { d.hide, "hide" },
        s = { d.show, "show" },
      },
      w = {
        name = "+workspace",
        a = { lb.add_workspace_folder, "add" },
        l = { function() print(vim.inspect(lb.list_workspace_folders())) end, "list" },
        r = { lb.remove_workspace_folder, "remove" },
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
    ["<C-k><C-k>"] = { function() bd.digraphs("r") end, "digraph" },
  },
  ["<leader>"] = {
    [" "] = { tb.oldfiles, "old files" },
    ["."] = { function() tb.find_files { hidden = true } end, "find files" },
    [","] = {
      name = "+language",
      g = {
        name = "+go",
        a = { ":GoAlt<cr>", "alternative file" },
        d = {
          name = "+debug",
          s = { ":GoDebug<cr>", "start" },
          t = { ":GoDbgStop<cr>", "stop" },
        },
        n = { ":lua require('dap-go').debug_test()<cr>", "run nearest test" },
      },
    },
    a = {
      name = "+translate",
      d = {
        name = "+deutsch",
        f = { ":Translate DE -output=floating<cr>", "floating" },
        g = { ":Translate DE -output=register<cr>", "register" },
        i = { ":Translate DE -output=insert<cr>", "insert" },
        r = { ":Translate DE -output=replace<cr>", "replace" },
        s = { ":Translate DE -output=split<cr>", "split" },
      },
      e = {
        name = "+english",
        f = { ":Translate EN -output=floating<cr>", "floating" },
        g = { ":Translate EN -output=register<cr>", "register" },
        i = { ":Translate EN -output=insert<cr>", "insert" },
        r = { ":Translate EN -output=replace<cr>", "replace" },
        s = { ":Translate EN -output=split<cr>", "split" },
      },
    },
    d = { ":MarkdownPreviewToggle<cr>", "markdown" },
    f = {
      name = "+telescope",
      a = { vim.lsp.buf.code_action, "lsp code actions" },
      A = { function() tb.find_files { hidden = true, no_ignore = true } end, "find all files" },
      b = { tb.buffers, "buffers" },
      d = { tb.lsp_definitions, "lsp definitions" },
      f = { tb.builtin, "builtin" },
      g = { tb.live_grep, "grep" },
      G = { function() tb.live_grep {
        additional_args = function() return { "-w" } end
      } end, "grep word" },
      h = { tb.help_tags, "help" },
      l = { tb.current_buffer_fuzzy_find, "fuzzy find" },
      o = { tb.vim_options, "vim options" },
      p = { t.extensions.neoclip.default, "paste" },
      q = { tb.quickfix, "quickfix" },
      Q = { tb.quickfixhistory, "quickfix history" },
      r = { tb.lsp_references, "lsp references" },
      R = { t.extensions.refactoring.refactors, "refactor" },
      s = { tb.grep_string, "grep string" },
      S = { function() tb.grep_string { word_match = "-w" } end, "grep string word" },
      t = { tb.tags, "tags" },
      T = { function() tb.tags { only_current_buffer = true } end, "local tags" },
      u = { ":UrlView packer picker=telescope<cr>", "packer plugins" },
      U = { ":UrlView buffer picker=telescope<cr>", "urls" },
      x = { ":TodoTelescope<cr>", "todos" },
      y = {
        name = "+grep type",
        g = {
          name = "go",
          g = { function() tb.live_grep { type_filter = "go" } end, "grep" },
          G = { function() tb.live_grep {
            type_filter = "go",
            additional_args = function() return { "-w" } end,
          } end, "grep word" },
          s = { function() tb.grep_string {
            additional_args = function() return { "--type=go" } end,
          } end, "grep string" },
          S = { function() tb.grep_string {
            additional_args = function() return { "--type=go" } end,
            word_match = "-w",
          } end, "grep string word" },
        },
        p = {
          name = "perl",
          g = { function() tb.live_grep { type_filter = "perl" } end, "grep" },
          G = { function() tb.live_grep {
            type_filter = "perl",
            additional_args = function() return { "-w" } end,
          } end, "grep word" },
          s = { function() tb.grep_string {
            additional_args = function() return { "--type=perl" } end,
          } end, "grep string" },
          S = { function() tb.grep_string {
            additional_args = function() return { "--type=perl" } end,
            word_match = "-w",
          } end, "grep string word" },
        },
      },
    },
    g = {
      name = "+git",
      g = { ":tab Git commit<cr>", "commit" },
    },
    h = {
      name = "+hunk",
      b = { function() require "gitsigns".blame_line { full = true } end, "blame" },
      d = { ":Gitsigns diffthis<cr>", "diff hunk" },
      D = { function() require "gitsigns".diffthis("~") end, "diff" },
      i = { ":Gitsigns show<cr>", "show index" },
      p = { ":Gitsigns preview_hunk<cr>", "preview hunk" },
      r = { ":Gitsigns reset_hunk<cr>", "reset hunk" },
      R = { ":Gitsigns reset_buffer<cr>", "reset_buffer" },
      s = { ":Gitsigns stage_hunk<cr>", "stage hunk" },
      S = { ":Gitsigns stage_buffer<cr>", "stage buffer" },
      u = { ":Gitsigns undo_stage_hunk<cr>", "unstage hunk" },
    },
    k = { "highlight word" },
    K = { "unhighlight words" },
    l = { [[:let @/ = ""<bar> :call UncolorAllWords()<cr>]], "unhighlight all" },
    m = { tb.git_status, "git" },
    p = {
      name = "+packer",
      s = { packer_sync, "sync" },
    },
    q = {
      name = "+quote",
      d = { [[ds']], "delete single", noremap = false },
      D = { [[ds"]], "delete double", noremap = false },
      q = { [[cs'"]], "single -> double", noremap = false },
      Q = { [[cs"']], "double -> single", noremap = false },
    },
    s = {
      name = "+spell",
      d = { ":setlocal spell spelllang=de_ch<cr>", "Deutsch" },
      e = { ":setlocal spell spelllang=en_gb<cr>", "English" },
      o = { ":set nospell<cr>", "off" },
    },
    t = {
      name = "+toggle",
      b = { ":Gitsigns toggle_current_line_blame<CR>", "blame" },
      d = { ":Gitsigns toggle_deleted<CR>", "deleted" },
      o = { ":SymbolsOutline<cr>", "symbols" },
      s = { function() require "sidebar-nvim".toggle() end, "sidebar" },
      t = { function() require "nvim-tree".toggle() end, "tree" },
    },
    W = { [[:%s/\s\+$//<cr>:let @/ = ""<cr>]], "remove trailing ws" },
  },
}

wk.register({
  ["<F1>"] = { ":Gitsigns stage_hunk<cr>", "stage lines" },
  glf = { lb.range_formatting, "format" },
  ["r<C-k><C-k>"] = { "<esc>:lua bd.digraphs('gvr')<cr>", "digraph" },
  ["<leader>"] = {
    a = {
      name = "+translate",
      d = {
        name = "+deutsch",
        f = { ":Translate DE -source=EN -output=floating<cr>", "floating" },
        g = { ":Translate DE -source=EN -output=register<cr>", "register" },
        i = { ":Translate DE -source=EN -output=insert<cr>", "insert" },
        r = { ":Translate DE -source=EN -output=replace<cr>", "replace" },
        s = { ":Translate DE -source=EN -output=split<cr>", "split" },
      },
      e = {
        name = "+english",
        f = { ":Translate EN -output=floating<cr>", "floating" },
        g = { ":Translate EN -output=register<cr>", "register" },
        i = { ":Translate EN -output=insert<cr>", "insert" },
        r = { ":Translate EN -output=replace<cr>", "replace" },
        s = { ":Translate EN -output=split<cr>", "split" },
      },
    },
    h = {
      name = "+hunk",
      r = { ":Gitsigns reset_hunk<cr>", "reset lines" },
      s = { ":Gitsigns stage_hunk<cr>", "stage lines" },
    },
    k = { "highlight word" },
  },
}, { mode = "v" })

wk.register({
  ["<F5>"] = { "[", "[", noremap = false },
  ["<F6>"] = { "]", "]", noremap = false },
  ["<F7>"] = { "{", "{", noremap = false },
  ["<F8>"] = { "}", "}", noremap = false },
  ["<F9>"] = { "|", "|" },
  ["<F10>"] = { "~", "~" },
  ["<C-k><C-k>"] = { function() bd.digraphs("gvr") end, "digraph" },
}, { mode = "i" })

local vmap = vim.api.nvim_set_keymap -- global mappings

vmap("n", "ga", "<Plug>(EasyAlign)", {})
vmap("x", "ga", "<Plug>(EasyAlign)", {})
vmap("v", "<Enter>", "<Plug>(EasyAlign)", {})

vmap("v", "<C-Up>", "<Plug>MoveBlockUp", {})
vmap("v", "<C-Down>", "<Plug>MoveBlockDown", {})
vmap("v", "<C-Left>", "<Plug>MoveBlockLeft", {})
vmap("v", "<C-Right>", "<Plug>MoveBlockRight", {})

vim.cmd [[
  cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

  inoremap <expr> <C-e> pumvisible() ? "\<C-y>\<C-e>" : "\<Esc>a\<C-e>"
  inoremap <expr> <C-y> pumvisible() ? "\<C-y>\<C-y>" : "\<C-y>"

  iabbr ,, =>
]]
