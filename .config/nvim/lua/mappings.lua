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

local function full_map(from, to)
  return { from, to, hidden = true, noremap = false, mode = "nvxsoitc" }
end

for i = 1, 12 do
  wk.add({
    full_map("<F" .. i + 12 .. ">", "<S-F" .. i .. ">"),
    full_map("<F" .. i + 24 .. ">", "<C-F" .. i .. ">"),
    full_map("<F" .. i + 36 .. ">", "<M-F" .. i .. ">"),
    full_map("<F" .. i + 48 .. ">", "<M-C-F" .. i .. ">"),
    full_map("<F" .. i + 60 .. ">", "<M-S-F" .. i .. ">"),
  })
end

wk.add({
  full_map("<M-5>", "<F5>"),
  full_map("<M-6>", "<F6>"),
  full_map("<M-7>", "<F7>"),
  full_map("<M-8>", "<F8>"),
  full_map("<M-9>", "<F9>"),
  full_map("<M-0>", "<F10>"),

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
  { "gd", lb.definition, desc = "definition" },
  { "gD", lb.declaration, desc = "declaration" },
  { "gi", lb.implementation, desc = "implementation" },
  { "gr", lb.references, desc = "references" },

  { "gl", group = "lsp" },
  { "gla", lb.code_action, desc = "action" },
  { "glD", lb.type_definition, desc = "type definition" },
  { "glf", desc = "format" },
  { "glf", lb.range_formatting, mode = "v", desc = "format" },
  { "glF", ":ALEFix<cr>", desc = "ALE fix" },
  { "gli", lb.incoming_calls, desc = "incoming calls" },
  { "glk", lb.signature_help, desc = "signature" },
  { "glK", lb.hover, desc = "hover" },
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
  {
    "<leader> q",
    function()
      require("replacer").run()
    end,
    desc = "quickfix replacer",
  },

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

  {
    mode = { "n", "v" },
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
  },

  { "<leader>.", smart_open, desc = "smart open" },
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

  { "<leader>f", group = "telescope" },
  { "<leader>,", group = "find files" },
  {
    "<leader>f,a",
    function()
      t.find_files({ hidden = true, no_ignore = true })
    end,
    desc = "include ignores",
  },
  {
    "<leader>f,c",
    function()
      t.find_files({ fd = require("local_defs").fn.common_fd(), hidden = true })
    end,
    desc = "common files",
  },
  { "<leader>f,f", ":Telescope frecency workspace=CWD<cr>", desc = "frecency" },
  {
    "<leader>f,g",
    function()
      t.git_files({ hidden = true })
    end,
    desc = "git files",
  },
  {
    "<leader>f,i",
    function()
      t.find_files({ hidden = true })
    end,
    desc = "honour ignores",
  },
  { "<leader>f,s", smart_open, desc = "smart open" },

  { "<leader>fa", vim.lsp.buf.code_action, desc = "code action" },
  {
    "<leader>fA",
    function()
      t.find_files({ hidden = true, no_ignore = true })
    end,
    desc = "find all files",
  },
  { "<leader>fb", tb.buffers, desc = "buffers" },

  {
    mode = { "n", "v" },
    { "<leader>fc", group = "copilot" },
    {
      "<leader>fcc",
      function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          require("CopilotChat").ask(
            input,
            { selection = require("CopilotChat.select").buffer }
          )
        end
      end,
      desc = "chat",
    },
    {
      "<leader>fch",
      function()
        local actions = require("CopilotChat.actions")
        require("CopilotChat.integrations.telescope").pick(
          actions.help_actions()
        )
      end,
      desc = "help",
    },
    {
      "<leader>fcp",
      function()
        local actions = require("CopilotChat.actions")
        require("CopilotChat.integrations.telescope").pick(
          actions.prompt_actions()
        )
      end,
      desc = "prompt",
    },
  },

  { "<leader>fC", tb.commands, desc = "commands" },

  { "<leader>fd", group = "diagnostics" },
  { "<leader>fdd", ":Telescope diagnostics<cr>", desc = "all" },
  {
    "<leader>fde",
    ":Telescope diagnostics severity=ERROR<cr>",
    desc = "error",
  },
  { "<leader>fdw", ":Telescope diagnostics severity=WARN<cr>", desc = "warn" },
  { "<leader>fdi", ":Telescope diagnostics severity=INFO<cr>", desc = "info" },
  { "<leader>fds", ":Telescope diagnostics severity=HINT<cr>", desc = "hint" },
  {
    "<leader>fdW",
    ":Telescope diagnostics severity_limit=WARN<cr>",
    desc = "warn",
  },
  {
    "<leader>fdI",
    ":Telescope diagnostics severity_limit=INFO<cr>",
    desc = "info",
  },

  { "<leader>fD", tb.lsp_diagnostics, desc = "lsp diagnostics" },
  { "<leader>fe", tb.resume, mode = { "n", "v" }, desc = "resume" },
  { "<leader>ff", tb.builtin, mode = { "n", "v" }, desc = "builtin" },
  { "<leader>fE", tb.treesitter, desc = "treesitter" },
  { "<leader>fg", tb.live_grep, desc = "live grep" },
  {
    "<leader>fG",
    function()
      tb.live_grep({
        additional_args = function()
          return { "-w" }
        end,
      })
    end,
    desc = "grep word",
  },
  { "<leader>fh", tb.help_tags, desc = "help tags" },
  { "<leader>fH", tb.highlights, desc = "highlights" },

  { "<leader>fi", group = "git" },
  { "<leader>fib", tb.git_branches, desc = "branches" },
  { "<leader>fic", tb.git_commits, desc = "commits" },
  { "<leader>fif", tb.git_files, desc = "files" },
  {
    "<leader>fih",
    t.extensions.git_file_history.git_file_history,
    desc = "file history",
  },
  { "<leader>fis", tb.git_status, desc = "status" },
  { "<leader>fit", tb.git_stash, desc = "stash" },
  { "<leader>fiu", tb.git_commits, desc = "buffer commits" },

  { "<leader>fj", tb.jumplist, desc = "jump list" },
  { "<leader>fJ", t.extensions.emoji.emoji, desc = "emoji" },
  { "<leader>fl", tb.current_buffer_fuzzy_find, desc = "fuzzy find" },
  { "<leader>fm", tb.keymaps, desc = "mappings" },
  { "<leader>fM", tb.man_pages, desc = "man pages" },
  {
    "<leader>fn",
    require("telescope").extensions.notify.notify,
    desc = "show notifications",
  },
  { "<leader>fo", tb.vim_options, desc = "vim options" },
  { "<leader>fO", tb.oldfiles, desc = "old files" },
  { "<leader>fp", t.extensions.neoclip.default, desc = "paste" },
  { "<leader>fP", ":UrlView lazy<cr>", desc = "plugins" },
  { "<leader>fq", tb.quickfix, desc = "quickfix" },
  { "<leader>fQ", tb.quickfixhistory, desc = "quickfix history" },
  { "<leader>fr", tb.lsp_references, desc = "lsp references" },
  { "<leader>fR", t.extensions.refactoring.refactors, desc = "refactor" },
  { "<leader>fs", tb.grep_string, mode = { "n", "v" }, desc = "grep string" },
  {
    "<leader>fS",
    function()
      tb.grep_string({ word_match = "-w" })
    end,
    desc = "grep string word",
  },
  { "<leader>ft", tb.tags, desc = "tags" },
  {
    "<leader>fT",
    function()
      tb.tags({ only_current_buffer = true })
    end,
    desc = "local tags",
  },
  { "<leader>fu", t.extensions.undo.undo, desc = "undo" },
  { "<leader>fU", ":UrlView buffer<cr>", desc = "urls" },
  {
    "<leader>fv",
    function()
      tb.tags({ default_text = vim.fn.expand("<cword>") })
    end,
    desc = "cword tags",
  },
  { "<leader>fx", ":TodoTelescope<cr>", desc = "todos" },
  { "<leader>fY", ":Telescope symbols<cr>", desc = "symbols" },

  { "<leader>fy", group = "type" },
  { "<leader>fyg", group = "go" },
  {
    "<leader>fygg",
    function()
      tb.live_grep({ type_filter = "go" })
    end,
    desc = "grep",
  },
  {
    "<leader>fygg",
    function()
      tb.live_grep({
        type_filter = "go",
        additional_args = function()
          return { "-w" }
        end,
      })
    end,
    desc = "grep word",
  },
  {
    "<leader>fygs",
    function()
      tb.grep_string({
        additional_args = function()
          return { "--type=go" }
        end,
      })
    end,
    mode = { "n", "v" },
    desc = "grep string",
  },
  {
    "<leader>fygS",
    function()
      tb.grep_string({
        additional_args = function()
          return { "--type=go" }
        end,
        word_match = "-w",
      })
    end,
    desc = "grep string",
  },

  { "<leader>fyp", group = "perl" },
  {
    "<leader>fypg",
    function()
      tb.live_grep({ type_filter = "perl" })
    end,
    desc = "grep",
  },
  {
    "<leader>fypg",
    function()
      tb.live_grep({
        type_filter = "perl",
        additional_args = function()
          return { "-w" }
        end,
      })
    end,
    desc = "grep word",
  },
  {
    "<leader>fyps",
    function()
      tb.grep_string({
        additional_args = function()
          return { "--type=perl" }
        end,
      })
    end,
    mode = { "n", "v" },
    desc = "grep string",
  },
  {
    "<leader>fypS",
    function()
      tb.grep_string({
        additional_args = function()
          return { "--type=perl" }
        end,
        word_match = "-w",
      })
    end,
    desc = "grep string",
  },

  { "<leader>g", group = "git" },
  {
    "<leader>gg",
    function()
      vim.opt.cmdheight = 2
      vim.cmd("tab Git commit")
      if vim.fn.getline(2) ~= "" then
        vim.cmd("normal O")
      end
      vim.cmd("startinsert")
    end,
    desc = "commit",
  },

  { "<leader>gl", group = "gitlab" },
  { "<leader>gla", gl.approve, desc = "approve" },

  { "<leader>glA", group = "assignee" },
  { "<leader>glAa", gl.add_assignee, desc = "add assignee" },
  { "<leader>glAd", gl.delete_assignee, desc = "delete assignee" },

  { "<leader>glc", gl.create_comment, desc = "create comment" },
  {
    "<leader>glc",
    gl.create_multiline_comment,
    mode = "v",
    desc = "create multiline comment",
  },
  { "<leader>gld", gl.toggle_discussions, desc = "toggle discussions" },

  { "<leader>gll", group = "label" },
  { "<leader>glla", gl.add_label, desc = "add label" },
  { "<leader>glld", gl.delete_label, desc = "delete label" },

  {
    "<leader>glm",
    gl.move_to_discussion_tree_from_diagnostic,
    desc = "move to discussion tree from diagnostic",
  },

  { "<leader>glM", group = "MR" },
  { "<leader>glMc", gl.create_mr, desc = "create mr" },
  { "<leader>glMm", gl.merge, desc = "merge" },

  { "<leader>gln", gl.create_note, desc = "create note" },
  { "<leader>glo", gl.open_in_browser, desc = "open in browser" },
  { "<leader>glp", gl.pipeline, desc = "pipeline" },
  { "<leader>glr", gl.review, desc = "review" },

  { "<leader>glR", group = "reviewer" },
  { "<leader>glRa", gl.add_reviewer, desc = "add reviewer" },
  { "<leader>glRd", gl.delete_reviewer, desc = "delete reviewer" },

  { "<leader>gls", gl.summary, desc = "summary" },
  {
    "<leader>gls",
    gl.create_comment_suggestion,
    mode = "v",
    desc = "create comment suggestion",
  },
  { "<leader>glV", gl.revoke, desc = "revoke" },

  { "<leader>h", group = "hunk" },
  {
    "<leader>hb",
    function()
      require("gitsigns").blame_line({ full = true })
    end,
    desc = "blame",
  },
  { "<leader>hd", ":Gitsigns diffthis<cr>", desc = "diff hunk" },
  {
    "<leader>hD",
    function()
      require("gitsigns").diffthis("~")
    end,
    desc = "diff",
  },
  { "<leader>hi", ":Gitsigns show<cr>", desc = "show index" },
  { "<leader>hp", ":Gitsigns preview_hunk<cr>", desc = "preview hunk" },
  {
    "<leader>hr",
    ":Gitsigns reset_hunk<cr>",
    mode = { "n", "v" },
    desc = "reset hunk",
  },
  { "<leader>hR", ":Gitsigns reset_buffer<cr>", desc = "reset_buffer" },
  {
    "<leader>hs",
    ":Gitsigns stage_hunk<cr>",
    mode = { "n", "v" },
    desc = "stage hunk",
  },
  { "<leader>hS", ":Gitsigns stage_buffer<cr>", desc = "stage buffer" },
  { "<leader>hu", ":Gitsigns undo_stage_hunk<cr>", desc = "unstage hunk" },

  { "<leader>k", mode = { "n", "v" }, desc = "highlight word" },
  { "<leader>K", mode = { "n", "v" }, desc = "unhighlight words" },
  {
    "<leader>l",
    [[:let @/ = ""<bar>:call UncolorAllWords()<cr>]],
    desc = "unhighlight all",
  },
  { "<leader>m", tb.git_status, desc = "find git changes" },
  { "<leader>n", ":NewFile<cr>", desc = "new file template" },

  { "<leader>q", group = "quote" },
  { "<leader>qb", [[ysiw`]], noremap = false, desc = "insert backtick" },
  { "<leader>qB", [[ds`]], noremap = false, desc = "delete backtick" },
  { "<leader>qd", [[ysiw"]], noremap = false, desc = "insert double" },
  { "<leader>qD", [[ds"]], noremap = false, desc = "delete double" },
  { "<leader>qq", [[cs'"]], noremap = false, desc = "single -> double" },
  { "<leader>qQ", [[cs"']], noremap = false, desc = "double -> single" },
  { "<leader>qs", [[ysiw']], noremap = false, desc = "insert single" },
  { "<leader>qS", [[ds']], noremap = false, desc = "delete single" },
  {
    "<leader>q(",
    [[ysiw(]],
    noremap = false,
    desc = "insert parentheses with space",
  },
  {
    "<leader>q)",
    [[ysiw)]],
    noremap = false,
    desc = "insert parentheses without space",
  },
  {
    "<leader>q{",
    [[ysiw{]],
    noremap = false,
    desc = "insert braces with space",
  },
  {
    "<leader>q}",
    [[ysiw}]],
    noremap = false,
    desc = "insert braces without space",
  },

  {
    "<leader>rr",
    ":mksess! /tmp/tmp_session.vim<cr>:xa<cr>",
    desc = "save session and exit",
  },

  { "<leader>s", group = "spell" },
  { "<leader>sd", ":setlocal spell spelllang=de_ch<cr>", desc = "Deutsch" },
  { "<leader>se", ":setlocal spell spelllang=en_gb<cr>", desc = "English" },
  { "<leader>so", ":set nospell<cr>", desc = "off" },

  { "<leader>t", group = "toggle" },
  { "<leader>tc", ":TSContextToggle<cr>", desc = "context" },

  { "<leader>tg", group = "git" },
  { "<leader>tgb", ":Gitsigns toggle_current_line_blame<cr>", desc = "blame" },
  { "<leader>tgd", ":Gitsigns toggle_deleted<cr>", desc = "deleted" },
  { "<leader>tgi", ":Gitsigns toggle_word_diff<cr>", desc = "diff" },
  { "<leader>tgl", ":Gitsigns toggle_linehl<cr>", desc = "line hl" },
  { "<leader>tgn", ":Gitsigns toggle_numhl<cr>", desc = "num hl" },
  { "<leader>tgs", ":Gitsigns toggle_signs<cr>", desc = "signs" },

  { "<leader>th", ":TSBufToggle highlight<cr>", desc = "treesitter highlight" },
  { "<leader>tl", ltext_toggle, desc = "lsp lines" },
  { "<leader>to", ":Outline<cr>", desc = "symbols" },
  {
    "<leader>ts",
    function()
      require("sidebar-nvim").toggle()
    end,
    desc = "sidebar",
  },
  { "<leader>tt", ":NvimTreeToggle<cr>", desc = "tree" },
  { "<leader>tv", vtext_toggle, desc = "virtual text" },
  { "<leader>tw", ":ToggleWhitespace<cr>", desc = "whitespace" },
  {
    "<leader>tx",
    function()
      require("hex").toggle()
    end,
    desc = "hex",
  },
  {
    "<leader>W",
    [[:%s/\s\+$//<cr>:let @/ = ""<cr>]],
    desc = "remove trailing ws",
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
