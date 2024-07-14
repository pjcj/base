--# selene: allow(mixed_table)

vim.g.mapleader = ","

local wk = require("which-key")
-- v2
-- {
--   mode = "n", -- NORMAL mode
--   prefix = "",
--   buffer = nil, -- Global mappings. Specify a buffer number for buffer local
--     mappings
--   silent = true, -- use `silent` when creating keymaps
--   noremap = true, -- use `noremap` when creating keymaps
--   nowait = false, -- use `nowait` when creating keymaps
--   expr = false, -- use `expr` when creating keymaps
-- }
-- v3
-- {
--   [1]: (string) lhs (required)
--   [2]: (string|fun()) rhs (optional): when present, it will create the
--     mapping
--   desc: (string) description (required)
--   mode: (string|string[]) mode (optional, defaults to "n")
--   group: (string) group name (optional)
--   cond: (boolean|fun():boolean) condition to enable the mapping (optional)
--   hidden: (boolean) hide the mapping (optional)
--   icon: (string|wk.Icon) icon spec (optional)
--   any other option valid for vim.keymap.set. These are only used for creating
--     mappings.
-- }

local lb = vim.lsp.buf
local d = vim.diagnostic
local t = require("telescope")
local tb = require("telescope.builtin")
local bd = require("better-digraphs")
local gs = require("gitsigns")
local gl = require("gitlab")
local tj = require("treesj")
local nt = require("neotest")

local vtext_on = true
local llines_on = false
local vtext_toggle = function()
  vtext_on = not vtext_on
  vim.diagnostic.config({ virtual_text = vtext_on })
  if vtext_on then
    llines_on = false
    vim.diagnostic.config({ virtual_lines = llines_on })
  end
end
local ltext_toggle = function()
  llines_on = not llines_on
  if llines_on then
    vim.diagnostic.config({ virtual_lines = { highlight_whole_line = false } })
  else
    vim.diagnostic.config({ virtual_lines = llines_on })
  end
  if llines_on then
    vtext_on = false
    vim.diagnostic.config({ virtual_text = vtext_on })
  end
end

-- parse a Perl stack trace from the + register into the quickfix list
local function load_perl_stack_trace()
  -- Get the content of the + register (clipboard)
  local clipboard_content = vim.fn.getreg("+")
  local lines = vim.split(clipboard_content, "\n")
  local quickfix_list = {}

  for _, line in ipairs(lines) do
    -- Perl stack trace line format: "at /path/to/file.pl line 123"
    local filename, lnum = line:match("at (%S+) line (%d+)")
    if filename and lnum then
      table.insert(quickfix_list, {
        filename = filename,
        lnum = tonumber(lnum),
        text = line,
      })
    end
  end

  vim.fn.setqflist(quickfix_list)
  vim.api.nvim_command("copen")
end

local function smart_open()
  require("telescope").extensions.smart_open.smart_open({
    cwd_only = true,
    filename_first = false,
    show_scores = false,
  })
end

wk.add({
  { "<F13>", "<S-F1>", hidden = true, noremap = false },
  { "<F14>", "<S-F2>", hidden = true, noremap = false },
  { "<F14>", "<S-F2>", hidden = true, noremap = false },
  { "<F16>", "<S-F4>", hidden = true, noremap = false },
  { "<F17>", "<S-F5>", hidden = true, noremap = false },
  { "<F18>", "<S-F6>", hidden = true, noremap = false },
  { "<F19>", "<S-F7>", hidden = true, noremap = false },
  { "<F20>", "<S-F8>", hidden = true, noremap = false },
  { "<F21>", "<S-F9>", hidden = true, noremap = false },
  { "<F22>", "<S-F10>", hidden = true, noremap = false },
  { "<F23>", "<S-F11>", hidden = true, noremap = false },
  { "<F24>", "<S-F12>", hidden = true, noremap = false },

  { "<F25>", "<C-F1>", hidden = true, noremap = false },
  { "<F26>", "<C-F2>", hidden = true, noremap = false },
  { "<F27>", "<C-F3>", hidden = true, noremap = false },
  { "<F28>", "<C-F4>", hidden = true, noremap = false },
  { "<F29>", "<C-F5>", hidden = true, noremap = false },
  { "<F30>", "<C-F6>", hidden = true, noremap = false },
  { "<F31>", "<C-F7>", hidden = true, noremap = false },
  { "<F32>", "<C-F8>", hidden = true, noremap = false },
  { "<F33>", "<C-F9>", hidden = true, noremap = false },
  { "<F34>", "<C-F10>", hidden = true, noremap = false },
  { "<F35>", "<C-F11>", hidden = true, noremap = false },
  { "<F36>", "<C-F12>", hidden = true, noremap = false },

  { "<F37>", "<C-F1>", hidden = true, noremap = false },
  { "<F38>", "<C-F2>", hidden = true, noremap = false },
  { "<F39>", "<C-F3>", hidden = true, noremap = false },
  { "<F40>", "<C-F4>", hidden = true, noremap = false },
  { "<F41>", "<C-F5>", hidden = true, noremap = false },
  { "<F42>", "<C-F6>", hidden = true, noremap = false },
  { "<F43>", "<C-F7>", hidden = true, noremap = false },
  { "<F44>", "<C-F8>", hidden = true, noremap = false },
  { "<F45>", "<C-F9>", hidden = true, noremap = false },
  { "<F46>", "<C-F10>", hidden = true, noremap = false },
  { "<F47>", "<C-F11>", hidden = true, noremap = false },
  { "<F48>", "<C-F12>", hidden = true, noremap = false },

  { "<F49>", "<C-F1>", hidden = true, noremap = false },
  { "<F50>", "<C-F2>", hidden = true, noremap = false },
  { "<F51>", "<C-F3>", hidden = true, noremap = false },
  { "<F52>", "<C-F4>", hidden = true, noremap = false },
  { "<F53>", "<C-F5>", hidden = true, noremap = false },
  { "<F54>", "<C-F6>", hidden = true, noremap = false },
  { "<F55>", "<C-F7>", hidden = true, noremap = false },
  { "<F56>", "<C-F8>", hidden = true, noremap = false },
  { "<F57>", "<C-F9>", hidden = true, noremap = false },
  { "<F58>", "<C-F10>", hidden = true, noremap = false },
  { "<F59>", "<C-F11>", hidden = true, noremap = false },
  { "<F60>", "<C-F12>", hidden = true, noremap = false },

  { "<F61>", "<M-S-F1>", hidden = true, noremap = false },
  { "<F62>", "<M-S-F2>", hidden = true, noremap = false },
  { "<F63>", "<M-S-F3>", hidden = true, noremap = false },
  { "<F64>", "<M-S-F4>", hidden = true, noremap = false },
  { "<F65>", "<M-S-F5>", hidden = true, noremap = false },
  { "<F66>", "<M-S-F6>", hidden = true, noremap = false },
  { "<F67>", "<M-S-F7>", hidden = true, noremap = false },
  { "<F68>", "<M-S-F8>", hidden = true, noremap = false },
  { "<F69>", "<M-S-F9>", hidden = true, noremap = false },
  { "<F70>", "<M-S-F10>", hidden = true, noremap = false },
  { "<F71>", "<M-S-F11>", hidden = true, noremap = false },
  { "<F72>", "<M-S-F12>", hidden = true, noremap = false },

  { "<M-5>", "<F5>", hidden = true, noremap = false },
  { "<M-5>", "<F5>", hidden = true, noremap = false },
  { "<M-5>", "<F5>", hidden = true, noremap = false },
  { "<M-5>", "<F5>", hidden = true, noremap = false },
  { "<M-5>", "<F5>", hidden = true, noremap = false },
  { "<M-5>", "<F5>", hidden = true, noremap = false },

  { "<F1>", gs.stage_hunk, mode = { "n", "v" }, desc = "stage hunk" },
  { "<F2>", gs.prev_hunk, desc = "previous hunk" },
  { "<F3>", gs.next_hunk, desc = "next hunk" },
  { "<S-F1>", ":q<cr>", desc = "quit" },
  { "<S-F2>", d.goto_prev, desc = "previous diagnostic" },
  { "<S-F3>", d.goto_next, desc = "next diagnostic" },
  { "<C-F2>", "<Plug>(ale_previous_wrap)", desc = "previous diagnostic" },
  { "<C-F3>", "<Plug>(ale_next_wrap)", desc = "next diagnostic" },
  {
    "<F4>",
    function()
      tb.tags({ default_text = vim.fn.expand("<cword>") })
    end,
    desc = "cword tags",
  },
  { "<F6>", ":cprevious<cr>", desc = "quickfix next" },
  { "<S-F6>", ":lprevious<cr>", desc = "location next" },
  { "<F7>", ":cnext<cr>", desc = "quickfix previous" },
  { "<S-F7>", ":lnext<cr>", desc = "location next" },
  { "<F9>", ":cclose<bar>lclose<bar>only<cr>", desc = "close other windows" },
  { "<C-F5>", "expand selection" },
  { "<C-F6>", "reduce selection" },
  { "<C-F7>", "expand selection to name" },
  { "<F12>", "", desc = "previous buffer" },

  { "<PageUp>", "0", desc = "page up" },
  { "<PageDown>", "0", desc = "page down" },
  { "<C-L>", desc = "refresh" },
  { "-", desc = "comment" },
  { "ä", desc = "show cursor" },
  { "ö", ":w<cr> | :wa<cr>", desc = "write all" },

  { "*", [[*<cmd>lua require("hlslens").start()<cr>]], desc = "next word" },
  { "#", [[#<cmd>lua require("hlslens").start()<cr>]], desc = "previous word" },
  {
    "g#",
    [[g#<cmd>lua require("hlslens").start()<cr>]],
    desc = "previous word part",
  },
  {
    "n",
    [[<cmd>execute("normal! " . v:count1 . "n")<cr><cmd>lua require("hlslens").start()<cr>]],
    desc = "next match",
  },
  {
    "N",
    [[<cmd>execute("normal! " . v:count1 . "N")<cr><cmd>lua require("hlslens").start()<cr>]],
    desc = "previous match",
  },

  { "g", group = "goto" },
  { "gD", lb.declaration, desc = "declaration" },
  { "gd", lb.definition, desc = "definition" },
  { "gi", lb.implementation, desc = "implementation" },
  { "gr", lb.references, desc = "references" },

  { "gl", group = "lsp" },
  { "gla", lb.code_action, desc = "action" },
  { "glD", lb.type_definition, desc = "type definition" },
  { "glf", "format" },
  { "glF", ":ALEFix<cr>", desc = "ALE fix" },
  { "gli", lb.incoming_calls, desc = "incoming calls" },
  { "glK", lb.hover, desc = "hover" },
  { "glk", lb.signature_help, desc = "signature" },
  { "gll", vim.diagnostic.open_float, desc = "show" },
  { "glo", lb.outgoing_calls, desc = "outgoing calls" },
  { "glq", vim.diagnostic.setqflist, desc = "quickfix" },
  { "glr", lb.rename, desc = "rename" },
  { "gls", lb.lsp_document_symbols, desc = "symbols" },

  { "glv", group = "virtual text" },
  { "glvh", d.hide, desc = "hide" },
  { "glvs", d.show, desc = "show" },

  { "glw", group = "workspace" },
  { "glwa", lb.add_workspace_folder, desc = "add" },
  {
    "glwl",
    function()
      print(vim.inspect(lb.list_workspace_folders()))
    end,
    desc = "list",
  },
  { "glwr", lb.remove_workspace_folder, desc = "remove" },

  { "gly", group = "tsserver" },
  { "glyi", ":TSLspImportAll<cr>", desc = "import all" },
  { "glyo", ":TSLspOrganize<cr>", desc = "organise" },
  { "glyr", ":TSLspRenameFile<cr>", desc = "rename file" },

  {
    mode = { "n", "v" },
    { "r", group = "replace" },
    { "r<F5>", "[", desc = "[" },
    { "r<F6>", "]", desc = "]" },
    { "r<F7>", "{", desc = "{" },
    { "r<F8>", "}", desc = "}" },
    { "r<F9>", "~", desc = "~" },
    { "r<F10>", "|", desc = "|" },
    { "r<F11>", "`", desc = "`" },
    { "r<C-k><C-k>", bd.digraphs, desc = "digraph" },
  },

  { "<leader>", group = "leader" },
  { "<leader> ", group = "plugin" },

  {
    mode = { "n", "v" },
    { "<leader> c", group = "ChatGPT" },
    { "<leader> cc", "<cmd>ChatGPT<cr>", desc = "ChatGPT" },
    {
      "<leader> ce",
      "<cmd>ChatGPTEditWithInstruction<cr>",
      desc = "edit with instruction",
    },
    {
      "<leader> cg",
      "<cmd>ChatGPTRun grammar_correction<cr>",
      desc = "grammar correction",
    },
    {
      "<leader> ct",
      "<cmd>ChatGPTRun translate<cr>",
      desc = "translate",
    },
    { "<leader> ck", "<cmd>ChatGPTRun keywords<cr>", desc = "Keywords" },
    {
      "<leader> cd",
      "<cmd>ChatGPTRun docstring<cr>",
      desc = "docstring",
    },
    { "<leader> ca", "<cmd>ChatGPTRun add_tests<cr>", desc = "add tests" },
    {
      "<leader> co",
      "<cmd>ChatGPTRun optimize_code<cr>",
      desc = "optimise code",
    },
    { "<leader> cs", "<cmd>ChatGPTRun summarize<cr>", desc = "summarize" },
    { "<leader> cf", "<cmd>ChatGPTRun fix_bugs<cr>", desc = "Fix Bugs" },
    {
      "<leader> cx",
      "<cmd>ChatGPTRun explain_code<cr>",
      desc = "explain code",
    },
    {
      "<leader> cr",
      "<cmd>ChatGPTRun roxygen_edit<cr>",
      desc = "roxygen edit",
    },
    {
      "<leader> cl",
      "<cmd>ChatGPTRun code_readability_analysis<cr>",
      desc = "code readability analysis",
    },
  },

  { "<leader> d", group = "diffview" },
  { "<leader> dc", ":DiffviewClose<cr>", desc = "close" },
  { "<leader> df", ":DiffviewFileHistory<cr>", desc = "file history" },
  { "<leader> dF", ":DiffviewFileHistory %<cr>", desc = "file history %" },
  { "<leader> do", ":DiffviewOpen<cr>", desc = "open" },

  { "<leader> j", group = "join" },
  { "<leader> jj", tj.join, desc = "join" },
  {
    "<leader> jJ",
    function()
      tj.join({ split = { recursive = true } })
    end,
    desc = "recursive join",
  },
  { "<leader> js", tj.split, desc = "split" },
  {
    "<leader> jS",
    function()
      tj.split({ split = { recursive = true } })
    end,
    desc = "recursive split",
  },
  { "<leader> jt", tj.toggle, desc = "toggle" },
  {
    "<leader> jT",
    function()
      tj.toggle({ split = { recursive = true } })
    end,
    desc = "recursive toggle",
  },

  { "<leader> m", ":MarkdownPreviewToggle<cr>", desc = "markdown" },

  {
    mode = { "n", "v" },
    { "<leader> n", group = "neural" },
    { "<leader> nb", "<Plug>(neural_buffer)", desc = "buffer" },
    {
      "<leader> nc",
      "<Plug>(neural_completion)",
      desc = "completion",
    },
    { "<leader> np", "<Plug>(neural_prompt)", desc = "prompt" },
    { "<leader> ns", "<Plug>(neural_stop)", desc = "stop" },
    { "<leader> nx", "<Plug>(neural_explain)", desc = "explain" },
  },

  { "<leader> l", group = "lazy" },
  { "<leader> lh", ":Lazy<cr>", desc = "home" },
  { "<leader> ls", ":Lazy sync<cr>", desc = "sync" },
  { "<leader> o", "<cmd>Oil --float<cr>", desc = "edit directory" },
  { "<leader> q", require("replacer").run, desc = "quickfix replacer" },

  { "<leader> r", group = "linter rules" },
  {
    "<leader> ri",
    function()
      require("rulebook").ignoreRule()
    end,
    desc = "ignore",
  },
  {
    "<leader> rl",
    function()
      require("rulebook").lookupRule()
    end,
    desc = "lookup rule",
  },
  {
    "<leader> rs",
    function()
      require("rulebook").suppressFormatter()
    end,
    mode = { "n", "x" },
    desc = "suppress formatter",
  },
  {
    "<leader> ry",
    function()
      require("rulebook").yankDiagnosticCode()
    end,
    desc = "yank diagnostic code",
  },

  { "<leader> t", group = "translate" },
  { "<leader> td", group = "deutsch" },
  { "<leader> tdf", ":Translate DE -output=floating<cr>", desc = "floating" },
  { "<leader> tdg", ":Translate DE -output=register<cr>", desc = "register" },
  { "<leader> tdi", ":Translate DE -output=insert<cr>", desc = "insert" },
  { "<leader> tdr", ":Translate DE -output=replace<cr>", desc = "replace" },
  { "<leader> tds", ":Translate DE -output=split<cr>", desc = "split" },

  { "<leader> te", group = "english" },
  { "<leader> tef", ":Translate EN -output=floating<cr>", desc = "floating" },
  { "<leader> teg", ":Translate EN -output=register<cr>", desc = "register" },
  { "<leader> tei", ":Translate EN -output=insert<cr>", desc = "insert" },
  { "<leader> ter", ":Translate EN -output=replace<cr>", desc = "replace" },
  { "<leader> tes", ":Translate EN -output=split<cr>", desc = "split" },

  { "<leader>,", smart_open, desc = "smart open" },
  {
    "<leader>-",
    function()
      tb.find_files({ hidden = true })
    end,
    desc = "honour ignores",
  },

  { "<leader>,", group = "language" },
  { "<leader>,g", group = "go" },
  { "<leader>,ga", ":GoAlt!<cr>", desc = "alternative file" },
  { "<leader>,gc", ":GoCoverage<cr>", desc = "coverage" },

  { "<leader>,gd", group = "debug" },
  { "<leader>,gds", ":GoDebug<cr>", desc = "start" },
  { "<leader>,gdt", ":GoDbgStop<cr>", desc = "stop" },

  {
    "<leader>,gi",
    function()
      local i = os.getenv("VIM_GO_IMPORT_LOCAL") or "xxxxxx"
      local gf = require("go.format")
      gf.goimport("-local", i)
      gf.gofmt()
    end,
    desc = "imports",
  },
  {
    "<leader>,gn",
    ":lua require('dap-go').debug_test()<cr>",
    desc = "run nearest test",
  },

  { "<leader>,gt", group = "test" },
  {
    "<leader>,gta",
    function()
      local file = "."
      print(file)
      nt.run.run(file)
    end,
    desc = "all",
  },
  {
    "<leader>,gtf",
    function()
      local file = vim.fn.expand("%")
      print(file)
      nt.run.run(file)
    end,
    desc = "file",
  },
  {
    "<leader>,gto",
    function()
      nt.output.open({ enter = true })
    end,
    desc = "open results",
  },
  {
    "<leader>,gts",
    function()
      nt.summary.toggle()
    end,
    desc = "toggle summary",
  },

  { "<leader>,p", group = "perl" },
  {
    "<leader>,ps",
    function()
      load_perl_stack_trace()
    end,
    desc = "stack trace to qf",
  },

  {
    mode = "i",
    { "<F5>", "[", noremap = false, desc = "[" },
    { "<F6>", "]", noremap = false, desc = "]" },
    { "<F7>", "{", noremap = false, desc = "{" },
    { "<F8>", "}", noremap = false, desc = "}" },
    { "<F9>", "~", noremap = false, desc = "~" },
    { "<F10>", "|", noremap = false, desc = "|" },
    { "<F11>", "`", noremap = false, desc = "`" },
    { "jk", "<esc>", desc = "escape" },
    {
      "<C-k><C-k>",
      function()
        bd.digraphs("insert")
      end,
      desc = "digraph",
    },
  },
})

wk.register({
  -- g = {
  -- name = "+goto",
  -- D = { lb.declaration, "declaration" },
  -- d = { lb.definition, "definition" },
  -- i = { lb.implementation, "implementation" },
  -- r = { lb.references, "references" },
  --   l = {
  --     name = "+lsp",
  --     a = { lb.code_action, "action" },
  --     D = { lb.type_definition, "type definition" },
  --     f = { "format" },
  --     F = { ":ALEFix<cr>", "ALE fix" },
  --     i = { lb.incoming_calls, "incoming calls" },
  --     K = { lb.hover, "hover" },
  --     k = { lb.signature_help, "signature" },
  --     l = { vim.diagnostic.open_float, "show" },
  --     o = { lb.outgoing_calls, "outgoing calls" },
  --     q = { vim.diagnostic.setqflist, "quickfix" },
  --     r = { lb.rename, "rename" },
  --     s = { lb.lsp_document_symbols, "symbols" },
  --     v = {
  --       name = "+virtual text",
  --       h = { d.hide, "hide" },
  --       s = { d.show, "show" },
  --     },
  --     w = {
  --       name = "+workspace",
  --       a = { lb.add_workspace_folder, "add" },
  --       l = {
  --         function()
  --           print(vim.inspect(lb.list_workspace_folders()))
  --         end,
  --         "list",
  --       },
  --       r = { lb.remove_workspace_folder, "remove" },
  --     },
  --     y = {
  --       name = "+tsserver",
  --       i = { ":TSLspImportAll<cr>", "import all" },
  --       o = { ":TSLspOrganize<cr>", "organise" },
  --       r = { ":TSLspRenameFile<cr>", "rename file" },
  --     },
  --   },
  -- },
  -- r = {
  --   name = "+replace",
  --   ["<F5>"] = { "r[", "[" },
  --   ["<F6>"] = { "r]", "]" },
  --   ["<F7>"] = { "r{", "{" },
  --   ["<F8>"] = { "r}", "}" },
  --   ["<F9>"] = { "r~", "~" },
  --   ["<F10>"] = { "r|", "|" },
  --   ["<F11>"] = { "r`", "`" },
  --   ["<C-k><C-k>"] = {
  --     function()
  --       bd.digraphs("normal")
  --     end,
  --     "digraph",
  --   },
  -- },
  ["<leader>"] = {
    -- [" "] = {
    --   name = "+plugin",
    --   c = {
    --     name = "ChatGPT",
    --     c = { "<cmd>ChatGPT<cr>", "ChatGPT" },
    --     e = {
    --       "<cmd>ChatGPTEditWithInstruction<cr>",
    --       "edit with instruction",
    --       mode = { "n", "v" },
    --     },
    --     g = {
    --       "<cmd>ChatGPTRun grammar_correction<cr>",
    --       "grammar correction",
    --       mode = { "n", "v" },
    --     },
    --     t = {
    --       "<cmd>ChatGPTRun translate<cr>",
    --       "translate",
    --       mode = { "n", "v" },
    --     },
    --     k = { "<cmd>ChatGPTRun keywords<cr>", "Keywords", mode = { "n", "v" } },
    --     d = {
    --       "<cmd>ChatGPTRun docstring<cr>",
    --       "docstring",
    --       mode = { "n", "v" },
    --     },
    --     a = {
    --       "<cmd>ChatGPTRun add_tests<cr>",
    --       "add tests",
    --       mode = { "n", "v" },
    --     },
    --     o = {
    --       "<cmd>ChatGPTRun optimize_code<cr>",
    --       "optimise code",
    --       mode = { "n", "v" },
    --     },
    --     s = {
    --       "<cmd>ChatGPTRun summarize<cr>",
    --       "summarize",
    --       mode = { "n", "v" },
    --     },
    --     f = { "<cmd>ChatGPTRun fix_bugs<cr>", "Fix Bugs", mode = { "n", "v" } },
    --     x = {
    --       "<cmd>ChatGPTRun explain_code<cr>",
    --       "explain code",
    --       mode = { "n", "v" },
    --     },
    --     r = {
    --       "<cmd>ChatGPTRun roxygen_edit<cr>",
    --       "roxygen edit",
    --       mode = { "n", "v" },
    --     },
    --     l = {
    --       "<cmd>ChatGPTRun code_readability_analysis<cr>",
    --       "code readability analysis",
    --       mode = { "n", "v" },
    --     },
    --   },
    --   d = {
    --     name = "+diffview",
    --     c = { ":DiffviewClose<cr>", "close" },
    --     f = { ":DiffviewFileHistory<cr>", "file history" },
    --     F = { ":DiffviewFileHistory %<cr>", "file history %" },
    --     o = { ":DiffviewOpen<cr>", "open" },
    --   },
    --   j = {
    --     name = "+join",
    --     j = { require("treesj").join, "join" },
    --     J = {
    --       function()
    --         require("treesj").join({ split = { recursive = true } })
    --       end,
    --       "recursive join",
    --     },
    --     s = { require("treesj").split, "split" },
    --     S = {
    --       function()
    --         require("treesj").split({ split = { recursive = true } })
    --       end,
    --       "recursive split",
    --     },
    --     t = { require("treesj").toggle, "toggle" },
    --     T = {
    --       function()
    --         require("treesj").toggle({ split = { recursive = true } })
    --       end,
    --       "recursive toggle",
    --     },
    --   },
    --   m = { ":MarkdownPreviewToggle<cr>", "markdown" },
    --   n = {
    --     name = "+neural",
    --     b = { "<Plug>(neural_buffer)", "buffer", mode = { "n", "v" } },
    --     c = { "<Plug>(neural_completion)", "completion", mode = { "n", "v" } },
    --     n = { "<Plug>(neural_prompt)", "prompt", mode = { "n", "v" } },
    --     s = { "<Plug>(neural_stop)", "stop", mode = { "n", "v" } },
    --     x = { "<Plug>(neural_explain)", "explain", mode = { "n", "v" } },
    --   },
    --   l = {
    --     name = "+lazy",
    --     h = { ":Lazy<cr>", "home" },
    --     s = { ":Lazy sync<cr>", "sync" },
    --   },
    --   o = { "<cmd>Oil --float<cr>", "edit directory" },
    --   q = { require("replacer").run, "quickfix replacer" },
    --   r = {
    --     name = "+linter rules",
    --     i = {
    --       function()
    --         require("rulebook").ignoreRule()
    --       end,
    --       "ignore",
    --     },
    --     l = {
    --       function()
    --         require("rulebook").lookupRule()
    --       end,
    --       "lookup rule",
    --     },
    --     s = {
    --       function()
    --         require("rulebook").suppressFormatter()
    --       end,
    --       "suppress formatter",
    --       mode = { "n", "x" },
    --     },
    --     y = {
    --       function()
    --         require("rulebook").yankDiagnosticCode()
    --       end,
    --       "yank diagnostic code",
    --     },
    --   },
    --   t = {
    --     name = "+translate",
    --     d = {
    --       name = "+deutsch",
    --       f = { ":Translate DE -output=floating<cr>", "floating" },
    --       g = { ":Translate DE -output=register<cr>", "register" },
    --       i = { ":Translate DE -output=insert<cr>", "insert" },
    --       r = { ":Translate DE -output=replace<cr>", "replace" },
    --       s = { ":Translate DE -output=split<cr>", "split" },
    --     },
    --     e = {
    --       name = "+english",
    --       f = { ":Translate EN -output=floating<cr>", "floating" },
    --       g = { ":Translate EN -output=register<cr>", "register" },
    --       i = { ":Translate EN -output=insert<cr>", "insert" },
    --       r = { ":Translate EN -output=replace<cr>", "replace" },
    --       s = { ":Translate EN -output=split<cr>", "split" },
    --     },
    --   },
    -- },

    -- ["."] = { smart_open, "smart open" },
    -- ["-"] = {
    --   function()
    --     tb.find_files({ hidden = true })
    --   end,
    --   "honour ignores",
    -- },
    -- [","] = {
    --   name = "+language",
    --   g = {
    --     name = "+go",
    --     a = { ":GoAlt!<cr>", "alternative file" },
    --     c = { ":GoCoverage<cr>", "coverage" },
    --     d = {
    --       name = "+debug",
    --       s = { ":GoDebug<cr>", "start" },
    --       t = { ":GoDbgStop<cr>", "stop" },
    --     },
    --     i = {
    --       function()
    --         local i = os.getenv("VIM_GO_IMPORT_LOCAL") or "xxxxxx"
    --         require("go.format").goimport("-local", i)
    --         require("go.format").gofmt()
    --       end,
    --       "imports",
    --     },
    --     n = { ":lua require('dap-go').debug_test()<cr>", "run nearest test" },
    --     t = {
    --       name = "+test",
    --       a = {
    --         function()
    --           local file = "."
    --           print(file)
    --           require("neotest").run.run(file)
    --         end,
    --         "all",
    --       },
    --       f = {
    --         function()
    --           local file = vim.fn.expand("%")
    --           print(file)
    --           require("neotest").run.run(file)
    --         end,
    --         "file",
    --       },
    --       o = {
    --         function()
    --           require("neotest").output.open({ enter = true })
    --         end,
    --         "open results",
    --       },
    --       s = {
    --         function()
    --           require("neotest").summary.toggle()
    --         end,
    --         "toggle summary",
    --       },
    --     },
    --   },
    --   p = {
    --     name = "+perl",
    --     s = {
    --       function()
    --         load_perl_stack_trace()
    --       end,
    --       "stack trace to qf",
    --     },
    --   },
    -- },
    f = {
      name = "+telescope",
      [","] = {
        name = "+find files",
        a = {
          function()
            tb.find_files({ hidden = true, no_ignore = true })
          end,
          "include ignored",
        },
        c = {
          function()
            tb.find_files({
              fd = require("local_defs").fn.common_fd(),
              hidden = true,
            })
          end,
          "common files",
        },
        f = { ":Telescope frecency workspace=CWD<cr>", "frecency" },
        g = {
          function()
            tb.git_files({ hidden = true })
          end,
          "git files",
        },
        i = {
          function()
            tb.find_files({ hidden = true })
          end,
          "honour ignores",
        },
        s = { smart_open, "smart open" },
      },
      a = { vim.lsp.buf.code_action, "lsp code actions" },
      A = {
        function()
          tb.find_files({ hidden = true, no_ignore = true })
        end,
        "find all files",
      },
      b = { tb.buffers, "buffers" },
      c = {
        name = "+copilot",
        c = {
          function()
            local input = vim.fn.input("Quick Chat: ")
            if input ~= "" then
              require("CopilotChat").ask(
                input,
                { selection = require("CopilotChat.select").buffer }
              )
            end
          end,
          "chat",
        },
        h = {
          function()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(
              actions.help_actions()
            )
          end,
          "help",
        },
        p = {
          function()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(
              actions.prompt_actions()
            )
          end,
          "prompt",
        },
      },
      C = { tb.commands, "commands" },
      d = {
        name = "+diagnostics",
        d = { ":Telescope diagnostics<cr>", "all" },
        e = { ":Telescope diagnostics severity=ERROR<cr>", "error" },
        w = { ":Telescope diagnostics severity=WARN<cr>", "warn" },
        i = { ":Telescope diagnostics severity=INFO<cr>", "info" },
        h = { ":Telescope diagnostics severity=HINT<cr>", "hint" },
        W = { ":Telescope diagnostics severity_limit=WARN<cr>", "warn" },
        I = { ":Telescope diagnostics severity_limit=INFO<cr>", "info" },
      },
      D = { tb.lsp_definitions, "lsp definitions" },
      e = { tb.resume, "resume" },
      E = { tb.treesitter, "tree sitter" },
      f = { tb.builtin, "builtin" },
      g = { tb.live_grep, "grep" },
      G = {
        function()
          tb.live_grep({
            additional_args = function()
              return { "-w" }
            end,
          })
        end,
        "grep word",
      },
      h = { tb.help_tags, "help" },
      H = { tb.highlights, "highlight colours" },
      i = {
        name = "+git",
        b = { tb.git_branches, "branches" },
        c = { tb.git_commits, "commits" },
        f = { tb.git_files, "files" },
        h = { t.extensions.git_file_history.git_file_history, "file history" },
        s = { tb.git_status, "status" },
        t = { tb.git_stash, "stash" },
        u = { tb.git_bcommits, "buffer commits" },
      },
      j = { tb.jumplist, "jump list" },
      J = { t.extensions.emoji.emoji, "emoji" },
      l = { tb.current_buffer_fuzzy_find, "fuzzy find" },
      m = { tb.keymaps, "mappings" },
      M = { tb.man_pages, "man pages" },
      n = {
        function()
          require("telescope").extensions.notify.notify()
        end,
        "show notifications",
      },
      o = { tb.vim_options, "vim options" },
      O = { tb.oldfiles, "old files" },
      p = { t.extensions.neoclip.default, "paste" },
      P = { ":UrlView lazy<cr>", "plugins" },
      q = { tb.quickfix, "quickfix" },
      Q = { tb.quickfixhistory, "quickfix history" },
      r = { tb.lsp_references, "lsp references" },
      R = { t.extensions.refactoring.refactors, "refactor" },
      s = { tb.grep_string, "grep string" },
      S = {
        function()
          tb.grep_string({ word_match = "-w" })
        end,
        "grep string word",
      },
      t = { tb.tags, "tags" },
      T = {
        function()
          tb.tags({ only_current_buffer = true })
        end,
        "local tags",
      },
      u = { t.extensions.undo.undo, "undo" },
      U = { ":UrlView buffer<cr>", "urls" },
      v = {
        function()
          tb.tags({ default_text = vim.fn.expand("<cword>") })
        end,
        "cword tags",
      },
      x = { ":TodoTelescope<cr>", "todos" },
      Y = { ":Telescope symbols<cr>", "symbols" },
      y = {
        name = "+grep type",
        g = {
          name = "go",
          g = {
            function()
              tb.live_grep({ type_filter = "go" })
            end,
            "grep",
          },
          G = {
            function()
              tb.live_grep({
                type_filter = "go",
                additional_args = function()
                  return { "-w" }
                end,
              })
            end,
            "grep word",
          },
          s = {
            function()
              tb.grep_string({
                additional_args = function()
                  return { "--type=go" }
                end,
              })
            end,
            "grep string",
          },
          S = {
            function()
              tb.grep_string({
                additional_args = function()
                  return { "--type=go" }
                end,
                word_match = "-w",
              })
            end,
            "grep string word",
          },
        },
        p = {
          name = "perl",
          g = {
            function()
              tb.live_grep({ type_filter = "perl" })
            end,
            "grep",
          },
          G = {
            function()
              tb.live_grep({
                type_filter = "perl",
                additional_args = function()
                  return { "-w" }
                end,
              })
            end,
            "grep word",
          },
          s = {
            function()
              tb.grep_string({
                additional_args = function()
                  return { "--type=perl" }
                end,
              })
            end,
            "grep string",
          },
          S = {
            function()
              tb.grep_string({
                additional_args = function()
                  return { "--type=perl" }
                end,
                word_match = "-w",
              })
            end,
            "grep string word",
          },
        },
      },
    },
    g = {
      name = "+git",
      g = {
        function()
          vim.opt.cmdheight = 2
          vim.cmd("tab Git commit")
          if vim.fn.getline(2) ~= "" then
            vim.cmd("normal O")
          end
          vim.cmd("startinsert")
        end,
        "commit",
      },
      l = {
        name = "+gitlab",
        a = { gl.approve, "approve" },
        A = {
          name = "+assignee",
          a = { gl.add_assignee, "add assignee" },
          d = { gl.delete_assignee, "delete assignee" },
        },
        c = { gl.create_comment, "create comment" },
        d = { gl.toggle_discussions, "toggle discussions" },
        l = {
          name = "+label",
          a = { gl.add_label, "add label" },
          d = { gl.delete_label, "delete label" },
        },
        m = {
          gl.move_to_discussion_tree_from_diagnostic,
          "move to discussion tree from diagnostic",
        },
        M = {
          name = "+MR",
          c = { gl.create_mr, "create mr" },
          m = { gl.merge, "merge" },
        },
        n = { gl.create_note, "create note" },
        o = { gl.open_in_browser, "open in browser" },
        p = { gl.pipeline, "pipeline" },
        r = { gl.review, "review" },
        R = {
          name = "+reviewer",
          a = { gl.add_reviewer, "add reviewer" },
          d = { gl.delete_reviewer, "delete reviewer" },
        },
        s = { gl.summary, "summary" },
        V = { gl.revoke, "revoke" },
      },
    },
    h = {
      name = "+hunk",
      b = {
        function()
          require("gitsigns").blame_line({ full = true })
        end,
        "blame",
      },
      d = { ":Gitsigns diffthis<cr>", "diff hunk" },
      D = {
        function()
          require("gitsigns").diffthis("~")
        end,
        "diff",
      },
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
    l = { [[:let @/ = ""<bar>:call UncolorAllWords()<cr>]], "unhighlight all" },
    m = { tb.git_status, "find git changes" },
    n = { ":NewFile<cr>", "new file template" },
    q = {
      name = "+quote",
      B = { [[ds`]], "delete backtick", noremap = false },
      b = { [[ysiw`]], "insert backtick", noremap = false },
      D = { [[ds"]], "delete double", noremap = false },
      d = { [[ysiw"]], "insert double", noremap = false },
      Q = { [[cs"']], "double -> single", noremap = false },
      q = { [[cs'"]], "single -> double", noremap = false },
      S = { [[ds']], "delete single", noremap = false },
      s = { [[ysiw']], "insert single", noremap = false },
      ["("] = { [[ysiw(]], "insert parentheses with space", noremap = false },
      [")"] = { [[ysiw)]], "insert parentheses without space", noremap = false },
      ["{"] = { [[ysiw{]], "insert braces with space", noremap = false },
      ["}"] = { [[ysiw}]], "insert braces without space", noremap = false },
    },
    r = { ":mksess! /tmp/tmp_session.vim<cr>:xa<cr>", "save session and exit" },
    s = {
      name = "+spell",
      d = { ":setlocal spell spelllang=de_ch<cr>", "Deutsch" },
      e = { ":setlocal spell spelllang=en_gb<cr>", "English" },
      o = { ":set nospell<cr>", "off" },
    },
    t = {
      name = "+toggle",
      -- C = {
      --   function()
      --     require("null-ls").toggle "codespell"
      --   end,
      --   "codespell",
      -- },
      c = { ":TSContextToggle<cr>", "context" },
      g = {
        name = "+git",
        b = { ":Gitsigns toggle_current_line_blame<cr>", "blame" },
        d = { ":Gitsigns toggle_deleted<cr>", "deleted" },
        i = { ":Gitsigns toggle_word_diff<cr>", "diff" },
        l = { ":Gitsigns toggle_linehl<cr>", "line hl" },
        n = { ":Gitsigns toggle_numhl<cr>", "num hl" },
        s = { ":Gitsigns toggle_signs<cr>", "signs" },
      },
      h = { ":TSBufToggle highlight<cr>", "treesitter highlight" },
      l = { ltext_toggle, "lsp lines" },
      o = { ":Outline<cr>", "symbols" },
      s = {
        function()
          require("sidebar-nvim").toggle()
        end,
        "sidebar",
      },
      t = { ":NvimTreeToggle<cr>", "tree" },
      v = { vtext_toggle, "virtual text" },
      w = { ":ToggleWhitespace<cr>", "whitespace" },
      x = {
        function()
          require("hex").toggle()
        end,
        "hex",
      },
    },
    W = { [[:%s/\s\+$//<cr>:let @/ = ""<cr>]], "remove trailing ws" },
  },
})

wk.register({
  -- ["<F1>"] = { ":Gitsigns stage_hunk<cr>", "stage lines" },
  -- ["r<C-k><C-k>"] = { "<esc>:lua bd.digraphs('visual')<cr>", "digraph" },
  ["<leader>"] = {
    -- [" "] = {
    --   name = "+plugin",
    --   c = { "ChatGPT" },
    --   h = {
    --     name = "+hunk",
    --     r = { ":Gitsigns reset_hunk<cr>", "reset lines" },
    --     s = { ":Gitsigns stage_hunk<cr>", "stage lines" },
    --   },
    --   k = { "highlight word" },
    --   n = { "neural" },
    --   t = {
    --     name = "+translate",
    --     d = {
    --       name = "+deutsch",
    --       f = { ":Translate DE -source=EN -output=floating<cr>", "floating" },
    --       g = { ":Translate DE -source=EN -output=register<cr>", "register" },
    --       i = { ":Translate DE -source=EN -output=insert<cr>", "insert" },
    --       r = { ":Translate DE -source=EN -output=replace<cr>", "replace" },
    --       s = { ":Translate DE -source=EN -output=split<cr>", "split" },
    --     },
    --     e = {
    --       name = "+english",
    --       f = { ":Translate EN -output=floating<cr>", "floating" },
    --       g = { ":Translate EN -output=register<cr>", "register" },
    --       i = { ":Translate EN -output=insert<cr>", "insert" },
    --       r = { ":Translate EN -output=replace<cr>", "replace" },
    --       s = { ":Translate EN -output=split<cr>", "split" },
    --     },
    --   },
    -- },
    f = {
      name = "+telescope",
      c = {
        name = "+copilot",
        c = {
          function()
            local input = vim.fn.input("Quick Chat: ")
            if input ~= "" then
              require("CopilotChat").ask(
                input,
                { selection = require("CopilotChat.select").buffer }
              )
            end
          end,
          "chat",
        },
        h = {
          function()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(
              actions.help_actions()
            )
          end,
          "help",
        },
        p = {
          function()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(
              actions.prompt_actions()
            )
          end,
          "prompt",
        },
      },
      e = { tb.resume, "resume" },
      f = { tb.builtin, "builtin" },
      s = { tb.grep_string, "grep string" },
      y = {
        name = "+grep type",
        g = {
          name = "go",
          s = {
            function()
              tb.grep_string({
                additional_args = function()
                  return { "--type=go" }
                end,
              })
            end,
            "grep string",
          },
        },
        p = {
          name = "perl",
          s = {
            function()
              tb.grep_string({
                additional_args = function()
                  return { "--type=perl" }
                end,
              })
            end,
            "grep string",
          },
        },
      },
    },
    g = {
      name = "+git",
      l = {
        name = "+gitlab",
        c = { gl.create_multiline_comment, "create multiline comment" },
        s = { gl.create_comment_suggestion, "create comment suggestion" },
      },
    },
  },
  g = {
    name = "+goto",
    l = {
      name = "+lsp",
      f = { lb.range_formatting, "format" },
    },
  },
}, { mode = "v" })

-- wk.register({
--   ["<F5>"] = { "[", "[", noremap = false },
--   ["<F6>"] = { "]", "]", noremap = false },
--   ["<F7>"] = { "{", "{", noremap = false },
--   ["<F8>"] = { "}", "}", noremap = false },
--   ["<F9>"] = { "~", "~" },
--   ["<F10>"] = { "|", "|" },
--   ["<F11>"] = { "`", "`" },
--   ["jk"] = { "<esc>", "escape" },
--   ["<C-k><C-k>"] = {
--     function()
--       bd.digraphs("insert")
--     end,
--     "digraph",
--   },
-- }, { mode = "i" })

vim.keymap.set("", "glf", function()
  require("notify")("formatting")
  require("conform").format({ async = true, lsp_fallback = true })
  require("notify")("formatted")
end)

local vmap = vim.api.nvim_set_keymap -- global mappings

vmap("n", "ga", "<Plug>(EasyAlign)", {})
vmap("x", "ga", "<Plug>(EasyAlign)", {})
vmap("v", "<Enter>", "<Plug>(EasyAlign)", {})

vmap("v", "<C-Up>", "<Plug>MoveBlockUp", {})
vmap("v", "<C-Down>", "<Plug>MoveBlockDown", {})
vmap("v", "<C-Left>", "<Plug>MoveBlockLeft", {})
vmap("v", "<C-Right>", "<Plug>MoveBlockRight", {})

-- vim.keymap.set({"n", "o", "x"}, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
-- vim.keymap.set({"n", "o", "x"}, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
-- vim.keymap.set({"n", "o", "x"}, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })
-- vim.keymap.set({"n", "o", "x"}, "ge", "<cmd>lua require('spider').motion('ge')<CR>", { desc = "Spider-ge" })

vim.cmd([[
  cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

  inoremap <expr> <C-e> pumvisible() ? "\<C-y>\<C-e>" : "\<Esc>a\<C-e>"
  inoremap <expr> <C-y> pumvisible() ? "\<C-y>\<C-y>" : "\<C-y>"

  iabbr ,, =>

  function! NewFile(type)
    " exe 'normal ggdG'
    exe 'r! file_template -path ' . &path . ' ' . expand('%') . ' ' . a:type
    exe 'normal ggdd'
    /^[ \t]*[#] *implementation/
    w
  endfunction
  command! -nargs=? NewFile :call NewFile(<q-args>)

  command! -nargs=+ Xshell 10new | execute "Shell" <q-args> | wincmd p
  command! -nargs=+ Sshell vnew | execute "Shell" <q-args> | wincmd p
]])
