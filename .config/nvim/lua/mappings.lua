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

local function aider_cmd(cmd)
  return function()
    vim.cmd(cmd)
    vim.cmd("stopinsert")
  end
end

local function aider_add_git_changes()
  -- Get all files with changes according to git
  local git_cmd = "git diff --name-only HEAD"
  local handle = io.popen(git_cmd)
  if not handle then
    vim.notify("Failed to execute git command", vim.log.levels.ERROR)
    return
  end

  local result = handle:read("*a")
  handle:close()

  if result == "" then
    vim.notify("No git changes found", vim.log.levels.INFO)
    return
  end

  local files = vim.split(result, "\n", { trimempty = true })

  -- Add each changed file to aider
  for _, file in ipairs(files) do
    if file ~= "" then
      require("nvim_aider").api.add_file(file)
    end
  end
  vim.cmd("stopinsert")

  vim.notify(
    "Added " .. #files .. " git-changed files to aider",
    vim.log.levels.INFO
  )
end

local function aider_add_all_windows()
  -- Get all open buffers in all windows
  local buffers = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(buf)
    -- Only add file buffers (not empty, terminal, or special buffers)
    if bufname ~= "" and vim.bo[buf].buftype == "" then
      buffers[bufname] = true
    end
  end

  -- Add each unique buffer to aider using the API
  for bufname, _ in pairs(buffers) do
    require("nvim_aider").api.add_file(bufname)
  end
  vim.cmd("stopinsert")

  -- Wait a moment for aider to potentially create new windows, then equalize
  vim.defer_fn(function()
    vim.cmd("wincmd =")
  end, 100)

  local count = 0
  for _ in pairs(buffers) do
    count = count + 1
  end
  vim.notify("Added " .. count .. " files to aider", vim.log.levels.INFO)
end

local function smart_star_search()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify(
      "No word under the cursor",
      vim.log.levels.WARN,
      { title = "Star Search" }
    )
    return
  end
  local search_pattern = "\\C\\V\\<" .. vim.fn.escape(word, "/\\") .. "\\>"
  -- Set the last search pattern register
  vim.fn.setreg("/", search_pattern)
  -- Execute a command that uses the last search pattern, like 'n'
  -- Then jump back to the original position
  vim.cmd("normal! n``")
  if pcall(require, "hlslens") then
    require("hlslens").start()
  end
end

-- 0: off, 1: virtual text, 2: virtual lines
local virtual_diagnostic_mode = 1
local function toggle_virtual_diagnostics()
  virtual_diagnostic_mode = (virtual_diagnostic_mode + 1) % 3
  if virtual_diagnostic_mode == 0 then
    vim.diagnostic.config({ virtual_text = false, virtual_lines = false })
    vim.notify(
      "Virtual diagnostics OFF",
      vim.log.levels.INFO,
      { title = "Diagnostics" }
    )
  elseif virtual_diagnostic_mode == 1 then
    vim.diagnostic.config({
      virtual_text = { prefix = "●" },
      virtual_lines = false,
    })
    vim.notify(
      "Virtual text ON",
      vim.log.levels.INFO,
      { title = "Diagnostics" }
    )
  else -- virtual_diagnostic_mode == 2
    vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
    vim.notify(
      "Virtual lines ON",
      vim.log.levels.INFO,
      { title = "Diagnostics" }
    )
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
  return { from, to, hidden = true, noremap = false, mode = "nvoitc" }
end

local function check_git_commit()
  local result = vim.fn.FugitiveResult()
  -- print(vim.inspect(result))
  if result.exit_status == nil or result.exit_status == 0 then
    if vim.fn.getline(2) ~= "" then
      vim.cmd("normal O")
    end
    vim.cmd("startinsert")
  else
    print("Git commit failed. Press Enter to continue.")
    vim.fn.input("")
  end
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

  { "<F1>", gs.stage_hunk, desc = "stage hunk" },
  {
    "<F1>",
    function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end,
    mode = "v",
    desc = "stage hunk",
  },
  { "<F2>", gs.prev_hunk, desc = "previous hunk" },
  { "<F3>", gs.next_hunk, desc = "next hunk" },
  { "<S-F1>", ":q<cr>", desc = "quit" },
  {
    "<S-F2>",
    function()
      vim.diagnostic.jump({ count = -1, float = true })
    end,
    desc = "previous diagnostic",
  },
  {
    "<S-F3>",
    function()
      vim.diagnostic.jump({ count = 1, float = true })
    end,
    desc = "next diagnostic",
  },
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

  { "*", smart_star_search, desc = "highlight word (case sensitive)" },
  {
    "#",
    [[*``<cmd>lua require("hlslens").start()<cr>]],
    desc = "highlight word (case insensitive)",
  },
  {
    "g*",
    [[g*``<cmd>lua require("hlslens").start()<cr>]],
    desc = "highlight word part",
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
  {
    "glf",
    function()
      require("conform").format({ async = true, lsp_fallback = true })
      require("notify")("formatted")
    end,
    mode = { "n", "v" },
    desc = "format",
  },
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
    { "r<C-k><C-k>", bd.digraphs, desc = "digraph" },
  },

  { "<leader>", group = "leader" },
  { "<leader> ", group = "plugin" },
  { "<leader>a", group = "avante" },

  {
    mode = { "n", "v" },

    { "<leader>  ", require("yazi").yazi, desc = "yazi" },
    { "<leader> .", group = "claude" },

    { "<leader> ,", group = "nvim-aider" },
    { "<leader> ,,", aider_cmd("Aider toggle"), desc = "toggle" },
    { "<leader> , ", aider_cmd("Aider"), desc = "picker" },
    {
      "<leader> ,s",
      aider_cmd("Aider send"),
      desc = "send",
      mode = { "n", "v" },
    },
    { "<leader> ,c", aider_cmd("Aider command"), desc = "commands" },
    { "<leader> ,b", aider_cmd("Aider buffer"), desc = "send buffer" },
    { "<leader> ,a", aider_cmd("Aider add"), desc = "add file" },
    { "<leader> ,d", aider_cmd("Aider drop"), desc = "drop file" },
    { "<leader> ,r", aider_cmd("Aider add readonly"), desc = "add read-only" },
    { "<leader> ,w", aider_add_all_windows, desc = "add all windows" },
    { "<leader> ,g", aider_add_git_changes, desc = "add git changes" },
    { "<leader> ,R", aider_cmd("Aider reset"), desc = "reset session" },
    {
      "<leader> ,l",
      require("nvim_aider").api.send_diagnostics_with_prompt,
      desc = "send lsp diagnostics",
    },

    { "<leader> ,t", group = "tree integration" },
    { "<leader> ,ta", aider_cmd("AiderTreeAddFile"), desc = "add from tree" },
    { "<leader> ,td", aider_cmd("AiderTreeDropFile"), desc = "drop from tree" },

    { "<leader> a", group = "parrot ai" },
    { "<leader> aI", "<cmd>PrtInfo<cr>", desc = "info" },
    { "<leader> aP", "<cmd>PrtProvider<cr>", desc = "provider" },
    { "<leader> aa", "<cmd>PrtAppend<cr>", desc = "append" },
    { "<leader> ai", "<cmd>PrtImplement<cr>", desc = "implement" },
    { "<leader> al", "<cmd>PrtLog<cr>", desc = "log" },
    { "<leader> am", "<cmd>PrtModel<cr>", desc = "model" },
    { "<leader> ap", "<cmd>PrtPrepend<cr>", desc = "prepend" },
    { "<leader> ar", "<cmd>PrtRewrite<cr>", desc = "rewrite" },

    { "<leader> ac", group = "chat" },
    { "<leader> acd", "<cmd>PrtChatDelete<cr>", desc = "delete" },
    { "<leader> acf", "<cmd>PrtChatFinder<cr>", desc = "finder" },
    { "<leader> acn", "<cmd>PrtChatNew<cr>", desc = "new" },
    { "<leader> acp", "<cmd>PrtChatPaste<cr>", desc = "paste" },
    { "<leader> acr", "<cmd>PrtChatRespond<cr>", desc = "respond" },
    { "<leader> acs", "<cmd>PrtChatStop<cr>", desc = "stop" },
    { "<leader> act", "<cmd>PrtChatToggle<cr>", desc = "toggle" },

    { "<leader> ah", group = "hooks" },
    { "<leader> ahb", "<cmd>PrtFixBugs<cr>", desc = "fix bugs" },
    { "<leader> ahc", "<cmd>PrtComplete<cr>", desc = "complete" },
    { "<leader> ahd", "<cmd>PrtDebug<cr>", desc = "debug" },
    { "<leader> ahe", "<cmd>PrtExplain<cr>", desc = "explain" },
    {
      "<leader> ahf",
      "<cmd>PrtCompleteFullContext<cr>",
      desc = "complete full context",
    },
    { "<leader> ahg", "<cmd>PrtCommitMsg<cr>", desc = "git commit msg" },
    {
      "<leader> ahm",
      "<cmd>PrtCompleteMultiContext<cr>",
      desc = "complete multi context",
    },
    { "<leader> aho", "<cmd>PrtOptimise<cr>", desc = "optimise" },
    { "<leader> ahp", "<cmd>PrtProofReader<cr>", desc = "proof reader" },
    { "<leader> ahs", "<cmd>PrtSpellCheck<cr>", desc = "spell check" },
    { "<leader> aht", "<cmd>PrtUnitTests<cr>", desc = "unit tests" },

    { "<leader> c", group = "CodeCompanion" },
    {
      "<leader> ca",
      function()
        require("codecompanion").actions()
      end,
      desc = "Actions",
    },
    {
      "<leader> cc",
      function()
        require("codecompanion").toggle()
      end,
      desc = "Chat",
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

  { "<leader> ", group = "plugins" },
  { "<leader>,", group = "language" },
  { "<leader>,a", group = "all" },
  {
    "<leader>,ai",
    function()
      local vopt = vim.opt
      vopt.shiftwidth = 2
      vopt.tabstop = 2
      vopt.expandtab = true
    end,
    desc = "set indentation",
  },
  -- { "<leader>,c", group = "copilot" },
  -- { "<leader>,cc", ":CopilotChatToggle<cr>", desc = "toggle" },
  -- {
  --   "<leader>,cq",
  --   function()
  --     local input = vim.fn.input("Quick Chat: ")
  --     if input ~= "" then
  --       require("CopilotChat").ask(
  --         input,
  --         { selection = require("CopilotChat.select").buffer }
  --       )
  --     end
  --   end,
  --   desc = "quick chat",
  -- },
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

  { "<leader>,l", group = "claude" },

  { "<leader>,p", group = "perl" },
  {
    "<leader>,ps",
    function()
      load_perl_stack_trace()
    end,
    desc = "stack trace to qf",
  },

  { "<leader>f", group = "telescope" },
  { "<leader>f,", group = "find files" },
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
      "<leader>fca",
      function()
        local actions = require("CopilotChat.actions")
        require("CopilotChat.integrations.telescope").pick(
          actions.prompt_actions()
        )
      end,
      desc = "actions",
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
  { "<leader>ft", tb.current_buffer_tags, desc = "local tags" },
  { "<leader>fT", tb.tags, desc = "tags" },
  { "<leader>fu", t.extensions.undo.undo, desc = "undo" },

  { "<leader>fU", group = "url" },
  { "<leader>fUu", ":UrlView buffer<cr>", desc = "yank url" },
  { "<leader>fUU", ":UrlView buffer action=system<cr>", desc = "open url" },
  { "<leader>fUl", ":UrlView lazy<cr>", desc = "yank lazy url" },
  { "<leader>fUL", ":UrlView lazy action=system<cr>", desc = "open lazy url" },
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
    "<leader>fygG",
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
    mode = { "n", "v" },
    desc = "grep string word",
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
    "<leader>fypG",
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
    mode = { "n", "v" },
    desc = "grep string word",
  },
  { "<leader>fz", tb.lsp_document_symbols, desc = "lsp symbols" },

  { "<leader>g", group = "git" },
  {
    "<leader>gg",
    function()
      vim.opt.cmdheight = 2
      vim.cmd("tab Git commit")
      check_git_commit()
    end,
    desc = "commit",
  },
  {
    "<leader>gG",
    function()
      vim.opt.cmdheight = 2
      vim.cmd("tab Git commit --no-verify")
      check_git_commit()
    end,
    desc = "commit --no-verify",
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
      gs.blame_line({ full = true })
    end,
    desc = "blame",
  },
  { "<leader>hd", gs.diffthis, desc = "diff hunk" },
  {
    "<leader>hD",
    function()
      gs.diffthis("~")
    end,
    desc = "diff",
  },
  { "<leader>hi", gs.preview_hunk_inline, desc = "preview hunk inline" },
  { "<leader>hp", gs.preview_hunk, desc = "preview hunk" },
  { "<leader>hr", gs.reset_hunk, desc = "reset hunk" },
  {
    "<leader>hr",
    function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end,
    mode = "v",
    desc = "reset hunk",
  },
  { "<leader>hR", gs.reset_buffer, desc = "reset_buffer" },
  { "<leader>hs", gs.stage_hunk, desc = "stage hunk" },
  {
    "<leader>hs",
    function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end,
    mode = "v",
    desc = "stage hunk",
  },
  { "<leader>hS", gs.stage_buffer, desc = "stage buffer" },
  { "<leader>hu", gs.undo_stage_hunk, desc = "unstage hunk" },
  { "<leader>hx", gs.show, desc = "show index" },

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

  { "<leader>r", group = "session & git" },
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
  { "<leader>t ", ":Yazi toggle<cr>", desc = "yazi" },
  { "<leader>tc", ":TSContextToggle<cr>", desc = "context" },

  { "<leader>tg", group = "git" },
  { "<leader>tgb", ":Gitsigns toggle_current_line_blame<cr>", desc = "blame" },
  { "<leader>tgd", ":Gitsigns toggle_deleted<cr>", desc = "deleted" },
  { "<leader>tgi", ":Gitsigns toggle_word_diff<cr>", desc = "diff" },
  { "<leader>tgl", ":Gitsigns toggle_linehl<cr>", desc = "line hl" },
  { "<leader>tgn", ":Gitsigns toggle_numhl<cr>", desc = "num hl" },
  { "<leader>tgs", ":Gitsigns toggle_signs<cr>", desc = "signs" },

  { "<leader>th", ":TSBufToggle highlight<cr>", desc = "treesitter highlight" },

  { "<leader>tm", group = "markdown" },
  { "<leader>tmp", ":MarkdownPreviewToggle<cr>", desc = "preview" },
  { "<leader>tmv", ":Markview toggle<cr>", desc = "view" },
  { "<leader>tms", ":Markview splitToggle<cr>", desc = "split" },

  { "<leader>to", ":Outline<cr>", desc = "symbols" },
  {
    "<leader>ts",
    function()
      require("sidebar-nvim").toggle()
    end,
    desc = "sidebar",
  },
  { "<leader>tt", ":NvimTreeToggle<cr>", desc = "tree" },
  {
    "<leader>tv",
    toggle_virtual_diagnostics,
    desc = "toggle virtual diagnostics",
  },
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
    "<leader>G",
    function()
      vim.fn.setreg("+", vim.fn.expand("%:p"))
    end,
    desc = "copy filename",
  },
  {
    "<leader><C-g>",
    function()
      vim.fn.setreg("+", vim.fn.expand("%"))
    end,
    desc = "copy relative filename",
  },

  {
    mode = "i",
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

local vmap = vim.api.nvim_set_keymap -- global mappings

vmap("n", "gA", "<Plug>(EasyAlign)", {})
vmap("x", "gA", "<Plug>(EasyAlign)", {})
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
