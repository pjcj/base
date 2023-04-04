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

local vtext_on = true
local vtext_toggle = function()
  vtext_on = not vtext_on
  vim.diagnostic.config({ virtual_text = vtext_on })
end

vim.cmd [[
  map <F13>    <S-F1>
  map <F14>    <S-F2>
  map <F15>    <S-F3>
  map <F16>    <S-F4>
  map <F17>    <S-F5>
  map <F18>    <S-F6>
  map <F19>    <S-F7>
  map <F20>    <S-F8>
  map <F21>    <S-F9>
  map <F22>    <S-F10>
  map <F23>    <S-F11>
  map <F24>    <S-F12>

  map <F25>    <C-F1>
  map <F26>    <C-F2>
  map <F27>    <C-F3>
  map <F28>    <C-F4>
  map <F29>    <C-F5>
  map <F30>    <C-F6>
  map <F31>    <C-F7>
  map <F32>    <C-F8>
  map <F33>    <C-F9>
  map <F34>    <C-F10>
  map <F35>    <C-F11>
  map <F36>    <C-F12>

  map <F37>    <M-F1>
  map <F38>    <M-F2>
  map <F39>    <M-F3>
  map <F40>    <M-F4>
  map <F41>    <M-F5>
  map <F42>    <M-F6>
  map <F43>    <M-F7>
  map <F44>    <M-F8>
  map <F45>    <M-F9>
  map <F46>    <M-F10>
  map <F47>    <M-F11>
  map <F48>    <M-F12>

  map <F49>    <M-C-F1>
  map <F50>    <M-C-F2>
  map <F51>    <M-C-F3>
  map <F52>    <M-C-F4>
  map <F53>    <M-C-F5>
  map <F54>    <M-C-F6>
  map <F55>    <M-C-F7>
  map <F56>    <M-C-F8>
  map <F57>    <M-C-F9>
  map <F58>    <M-C-F10>
  map <F59>    <M-C-F11>
  map <F60>    <M-C-F12>

  " Creates map mappings for <<
  " map <F61>    <M-S-F1>
  " map <F62>    <M-S-F2>
  " map <F63>    <M-S-F3>
  " map <F64>    <M-S-F4>
  " map <F65>    <M-S-F5>
  " map <F66>    <M-S-F6>
  " map <F67>    <M-S-F7>
  " map <F68>    <M-S-F8>
  " map <F69>    <M-S-F9>
  " map <F70>    <M-S-F10>
  " map <F71>    <M-S-F11>
  " map <F72>    <M-S-F12>
]]

wk.register {
  ["<F1>"] = { gs.stage_hunk, "stage hunk" },
  ["<F2>"] = { gs.prev_hunk, "previous hunk" },
  ["<F3>"] = { gs.next_hunk, "next hunk" },
  ["<S-F1>"] = { ":q<cr>", "quit" },
  ["<S-F2>"] = { d.goto_prev, "previous diagnostic" },
  ["<S-F3>"] = { d.goto_next, "next diagnostic" },
  ["<C-F2>"] = { "<Plug>(ale_previous_wrap)", "previous diagnostic" },
  ["<C-F3>"] = { "<Plug>(ale_next_wrap)", "next diagnostic" },
  -- ["<F4>"] = { [[:execute "tjump /^\\(_build_\\)\\?" . expand("<cword>") . "$"<cr>]], "jump to tag" },
  ["<F4>"] = { function() tb.tags { default_text = vim.fn.expand("<cword>") } end, "cword tags" },
  ["<F6>"] = { ":cprevious<cr>", "quickfix next" },
  ["<S-F6>"] = { ":lprevious<cr>", "location next" },
  ["<F7>"] = { ":cnext<cr>", "quickfix previous" },
  ["<S-F7>"] = { ":lnext<cr>", "location next" },
  ["<F9>"] = { ":cclose<bar>lclose<bar>only<cr>", "close other windows" },
  ["<C-F5>"] = { "expand selection" },
  ["<C-F6>"] = { "reduce selection" },
  ["<C-F7>"] = { "expand selection to name" },
  ["<F12>"] = { "", "previous buffer" },
  ["<PageUp>"] = { "0", "page up" },
  ["<PageDown>"] = { "0", "page down" },
  ["<C-L>"] = { "refresh" },
  ["-"] = { "comment" },
  ["ä"] = { "show cursor" },
  ["ö"] = { ":w<cr> | :wa<cr>", "write all" },

  ["n"] = { [[<cmd>execute("normal! " . v:count1 . "n")<cr><cmd>lua require("hlslens").start()<cr>]], "next match" },
  ["N"] = { [[<cmd>execute("normal! " . v:count1 . "N")<cr><cmd>lua require("hlslens").start()<cr>]], "previous match" },
  ["*"] = { [[*<cmd>lua require("hlslens").start()<cr>]], "next word" },
  ["#"] = { [[#<cmd>lua require("hlslens").start()<cr>]], "previous word" },
  ["g*"] = { [[g*<cmd>lua require("hlslens").start()<cr>]], "next word part" },
  ["g#"] = { [[g#<cmd>lua require("hlslens").start()<cr>]], "previous word part" },

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
      s = { lb.lsp_document_symbols, "symbols" },
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
  },
  r = {
    name = "+replace",
    ["<F5>"] = { "r[", "[" },
    ["<F6>"] = { "r]", "]" },
    ["<F7>"] = { "r{", "{" },
    ["<F8>"] = { "r}", "}" },
    ["<F9>"] = { "r|", "|" },
    ["<F10>"] = { "r~", "~" },
    ["<C-k><C-k>"] = { function() bd.digraphs("normal") end, "digraph" },
  },
  ["<leader>"] = {
    [" "] = {
      name = "+plugin",
      m = { ":MarkdownPreviewToggle<cr>", "markdown" },
      p = {
        name = "+packer",
        c = { ":PackerCompile<cr>", "compile" },
        s = { packer_sync, "sync" },
      },
      t = {
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
    },
    ["."] = { function() tb.find_files { hidden = true } end, "find files" },
    [","] = {
      name = "+language",
      g = {
        name = "+go",
        a = { ":GoAlt!<cr>", "alternative file" },
        c = { ":GoCoverage<cr>", "coverage" },
        d = {
          name = "+debug",
          s = { ":GoDebug<cr>", "start" },
          t = { ":GoDbgStop<cr>", "stop" },
        },
        i = { function()
          local i = os.getenv("VIM_GO_IMPORT_LOCAL") or "xxxxxx"
          require "go.format".goimport("-local", i)
          require "go.format".gofmt()
        end, "imports" },
        n = { ":lua require('dap-go').debug_test()<cr>", "run nearest test" },
        t = {
          name = "+test",
          a = { function()
            local file = "."
            print(file)
            require "neotest".run.run(file)
          end, "all" },
          f = { function()
            local file = vim.fn.expand("%")
            print(file)
            require "neotest".run.run(file)
          end, "file" },
          o = { function()
            require "neotest".output.open({ enter = true })
          end, "open results" },
          s = { function()
            require "neotest".summary.toggle()
          end, "toggle summary" },
        },
      },
    },
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
      j = { tb.jumplist, "jump list" },
      l = { tb.current_buffer_fuzzy_find, "fuzzy find" },
      n = { function() require "telescope".extensions.notify.notify() end, "show notifications" },
      o = { tb.vim_options, "vim options" },
      O = { tb.oldfiles, "old files" },
      p = { t.extensions.neoclip.default, "paste" },
      P = { ":UrlView packer<cr>", "packer plugins" },
      q = { tb.quickfix, "quickfix" },
      Q = { tb.quickfixhistory, "quickfix history" },
      r = { tb.lsp_references, "lsp references" },
      R = { t.extensions.refactoring.refactors, "refactor" },
      s = { tb.grep_string, "grep string" },
      S = { function() tb.grep_string { word_match = "-w" } end, "grep string word" },
      t = { tb.tags, "tags" },
      T = { function() tb.tags { only_current_buffer = true } end, "local tags" },
      u = { t.extensions.undo.undo, "undo" },
      U = { ":UrlView buffer<cr>", "urls" },
      v = { function() tb.tags { default_text = vim.fn.expand("<cword>") } end, "cword tags" },
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
    m = { tb.git_status, "find git changes" },
    q = {
      name = "+quote",
      d = { [[ds']], "delete single", noremap = false },
      D = { [[ds"]], "delete double", noremap = false },
      i = { [[ysiw']], "insert single", noremap = false },
      I = { [[ysiw"]], "insert double", noremap = false },
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
      c = { function() require "null-ls".toggle("codespell") end, "codespell" },
      d = { ":Gitsigns toggle_deleted<CR>", "deleted" },
      h = { ":TSBufToggle highlight<cr>", "treesitter highlight" },
      o = { ":SymbolsOutline<cr>", "symbols" },
      s = { function() require "sidebar-nvim".toggle() end, "sidebar" },
      t = { function() require "nvim-tree".toggle() end, "tree" },
      v = { vtext_toggle, "virtual text" },
      x = { function() require "hex".toggle() end, "hex" },
    },
    W = { [[:%s/\s\+$//<cr>:let @/ = ""<cr>]], "remove trailing ws" },
  },
}

wk.register({
  ["<F1>"] = { ":Gitsigns stage_hunk<cr>", "stage lines" },
  glf = { lb.range_formatting, "format" },
  ["r<C-k><C-k>"] = { "<esc>:lua bd.digraphs('visual')<cr>", "digraph" },
  ["<leader>"] = {
    [" "] = {
      name = "+plugin",
      t = {
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
    f = {
      name = "+telescope",
      s = { tb.grep_string, "grep string" },
      y = {
        name = "+grep type",
        g = {
          name = "go",
          s = { function() tb.grep_string {
            additional_args = function() return { "--type=go" } end,
          } end, "grep string" },
        },
        p = {
          name = "perl",
          s = { function() tb.grep_string {
            additional_args = function() return { "--type=perl" } end,
          } end, "grep string" },
        },
      },
    },
  },
}, { mode = "v" })

wk.register({
  ["<F5>"] = { "[", "[", noremap = false },
  ["<F6>"] = { "]", "]", noremap = false },
  ["<F7>"] = { "{", "{", noremap = false },
  ["<F8>"] = { "}", "}", noremap = false },
  ["<F9>"] = { "|", "|" },
  ["<F10>"] = { "~", "~" },
  ["jk"] = { "<esc>", "escape" },
  ["<C-k><C-k>"] = { function() bd.digraphs("insert") end, "digraph" },
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
