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
local function t()
  return require("telescope")
end
local function tb()
  return require("telescope.builtin")
end
local function bd()
  return require("better-digraphs")
end
local function gs()
  return require("gitsigns")
end
local function gl()
  return require("gitlab")
end
local function tj()
  return require("treesj")
end
local function nt()
  return require("neotest")
end
local function ss()
  return require("smart-splits")
end

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

local diagnostic_modes = {
  { -- Mode 1: Virtual Text
    config = { virtual_text = { prefix = "●" }, virtual_lines = false },
    message = "Virtual text ON",
  },
  { -- Mode 2: Virtual Lines
    config = { virtual_text = false, virtual_lines = true },
    message = "Virtual lines ON",
  },
  { -- Mode 3: Off
    config = { virtual_text = false, virtual_lines = false },
    message = "Virtual diagnostics OFF",
  },
}
local current_diagnostic_mode = 1
local function toggle_virtual_diagnostics()
  current_diagnostic_mode = (current_diagnostic_mode % #diagnostic_modes) + 1
  local mode = diagnostic_modes[current_diagnostic_mode]
  vim.diagnostic.config(mode.config)
  vim.notify(mode.message, vim.log.levels.INFO, { title = "Diagnostics" })
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
  t().extensions.smart_open.smart_open({
    cwd_only = true,
    filename_first = false,
    show_scores = false,
  })
end

local function full_map(from, to)
  return { from, to, hidden = true, noremap = false, mode = "nvoitc" }
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

  -- Smart splits navigation
  {
    "<C-h>",
    function()
      ss().move_cursor_left()
    end,
    desc = "move left",
  },
  {
    "<C-j>",
    function()
      ss().move_cursor_down()
    end,
    desc = "move down",
  },
  {
    "<C-k>",
    function()
      ss().move_cursor_up()
    end,
    desc = "move up",
  },
  {
    "<C-l>",
    function()
      ss().move_cursor_right()
    end,
    desc = "move right",
  },

  -- Smart splits resizing
  {
    "<A-h>",
    function()
      ss().resize_left()
    end,
    desc = "resize left",
  },
  {
    "<A-j>",
    function()
      ss().resize_down()
    end,
    desc = "resize down",
  },
  {
    "<A-k>",
    function()
      ss().resize_up()
    end,
    desc = "resize up",
  },
  {
    "<A-l>",
    function()
      ss().resize_right()
    end,
    desc = "resize right",
  },

  {
    "<F1>",
    function()
      gs().stage_hunk()
    end,
    desc = "stage hunk",
  },
  {
    "<F1>",
    function()
      gs().stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end,
    mode = "v",
    desc = "stage hunk",
  },
  {
    "<F2>",
    function()
      gs().prev_hunk()
    end,
    desc = "previous hunk",
  },
  {
    "<F3>",
    function()
      gs().next_hunk()
    end,
    desc = "next hunk",
  },
  { "<S-F1>", ":q<cr>",            desc = "quit" },
  { "<S-F1>", "<C-\\><C-n>:q<cr>", mode = "i",   desc = "quit" },
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
  { "<C-F3>", "<Plug>(ale_next_wrap)",     desc = "next diagnostic" },
  {
    "<F4>",
    function()
      tb().tags({ default_text = vim.fn.expand("<cword>") })
    end,
    desc = "cword tags",
  },
  { "<F6>",       ":cprevious<cr>",                  desc = "quickfix next" },
  { "<S-F6>",     ":lprevious<cr>",                  desc = "location next" },
  { "<F7>",       ":cnext<cr>",                      desc = "quickfix previous" },
  { "<S-F7>",     ":lnext<cr>",                      desc = "location next" },
  { "<F9>",       ":cclose<bar>lclose<bar>only<cr>", desc = "close other windows" },
  { "<C-F5>",     "expand selection" },
  { "<C-F6>",     "reduce selection" },
  { "<C-F7>",     "expand selection to name" },
  { "<F12>",      "",                               desc = "previous buffer" },

  { "<PageUp>",   "0",                              desc = "page up" },
  { "<PageDown>", "0",                              desc = "page down" },
  { "-",          desc = "comment" },
  { "ä",          desc = "show cursor" },
  { "ö",          ":w<cr> | :wa<cr>",                desc = "write all" },

  { "*",          smart_star_search,                 desc = "highlight word (case sensitive)" },
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

  { "g",   group = "goto" },
  { "gd",  lb.definition,      desc = "definition" },
  { "gD",  lb.declaration,     desc = "declaration" },
  { "gi",  lb.implementation,  desc = "implementation" },
  { "gr",  lb.references,      desc = "references" },

  { "gl",  group = "lsp" },
  { "gla", lb.code_action,     desc = "action" },
  { "glD", lb.type_definition, desc = "type definition" },
  {
    "glf",
    function()
      vim.notify("Formatting...", vim.log.levels.INFO, { title = "Format" })
      require("conform").format(
        { async = true, lsp_format = "last" },
        function(err, did_edit)
          if err then
            vim.notify(
              "Formatting error: " .. err,
              vim.log.levels.ERROR,
              { title = "Format" }
            )
            return
          elseif not did_edit then
            vim.notify("No formatting changes needed", vim.log.levels.INFO, {
              title = "Format",
            })
            return
          end
          vim.notify("Formatted", vim.log.levels.INFO, { title = "Format" })
        end
      )
    end,
    mode = { "n", "v" },
    desc = "format",
  },
  { "glF",  ":ALEFix<cr>",             desc = "ALE fix" },
  { "gli",  lb.incoming_calls,         desc = "incoming calls" },
  { "glk",  lb.signature_help,         desc = "signature" },
  { "glK",  lb.hover,                  desc = "hover" },
  { "gll",  vim.diagnostic.open_float, desc = "show" },
  { "glo",  lb.outgoing_calls,         desc = "outgoing calls" },
  { "glq",  vim.diagnostic.setqflist,  desc = "quickfix" },
  { "glr",  lb.rename,                 desc = "rename" },
  { "gls",  lb.lsp_document_symbols,   desc = "symbols" },

  { "glv",  group = "virtual text" },
  { "glvh", d.hide,                    desc = "hide" },
  { "glvs", d.show,                    desc = "show" },

  { "glw",  group = "workspace" },
  { "glwa", lb.add_workspace_folder,   desc = "add" },
  {
    "glwl",
    function()
      print(vim.inspect(lb.list_workspace_folders()))
    end,
    desc = "list",
  },
  { "glwr", lb.remove_workspace_folder, desc = "remove" },

  { "gly",  group = "tsserver" },
  { "glyi", ":TSLspImportAll<cr>",      desc = "import all" },
  { "glyo", ":TSLspOrganize<cr>",       desc = "organise" },
  { "glyr", ":TSLspRenameFile<cr>",     desc = "rename file" },

  -- breaks works at snake and camel case boundaries
  { "gl",  group = "spider" },
  {
    "gpw",
    function() require("spider").motion("w") end,
    mode = { "n", "o", "x" },
    desc = "Spider-w"
  },
  {
    "gpe",
    function() require("spider").motion("e") end,
    mode = { "n", "o", "x" },
    desc = "Spider-e"
  },
  {
    "gpb",
    function() require("spider").motion("b") end,
    mode = { "n", "o", "x" },
    desc = "Spider-b"
  },
  {
    "gpge",
    function() require("spider").motion("ge") end,
    mode = { "n", "o", "x" },
    desc = "Spider-ge"
  },

  {
    mode = { "n", "v" },
    { "r", group = "replace" },
    {
      "r<C-k><C-k>",
      function()
        bd().digraphs()
      end,
      desc = "digraph",
    },
  },

  { "<leader>",  group = "leader" },
  { "<leader> ", group = "plugin" },
  { "<leader>a", group = "avante" },

  {
    mode = { "n", "v" },

    {
      "<leader>  ",
      function()
        require("yazi").yazi()
      end,
      desc = "yazi",
    },
    { "<leader> .",  group = "claudecode" },

    { "<leader> ,",  group = "opencode" },

    { "<leader> a",  group = "nvim-aider" },
    { "<leader> a,", aider_cmd("Aider toggle"), desc = "toggle" },
    { "<leader> a ", aider_cmd("Aider"),        desc = "picker" },
    {
      "<leader> as",
      aider_cmd("Aider send"),
      desc = "send",
      mode = { "n", "v" },
    },
    { "<leader> ac", aider_cmd("Aider command"),      desc = "commands" },
    { "<leader> ab", aider_cmd("Aider buffer"),       desc = "send buffer" },
    { "<leader> aa", aider_cmd("Aider add"),          desc = "add file" },
    { "<leader> ad", aider_cmd("Aider drop"),         desc = "drop file" },
    { "<leader> ar", aider_cmd("Aider add readonly"), desc = "add read-only" },
    { "<leader> aw", aider_add_all_windows,           desc = "add all windows" },
    { "<leader> ag", aider_add_git_changes,           desc = "add git changes" },
    { "<leader> aR", aider_cmd("Aider reset"),        desc = "reset session" },
    {
      "<leader> al",
      function()
        require("nvim_aider").api.send_diagnostics_with_prompt()
      end,
      desc = "send lsp diagnostics",
    },
    { "<leader> at",  group = "tree integration" },
    { "<leader> ata", aider_cmd("AiderTreeAddFile"),  desc = "add from tree" },
    { "<leader> atd", aider_cmd("AiderTreeDropFile"), desc = "drop from tree" },

    { "<leader> c",   group = "CodeCompanion" },
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

  { "<leader> d",  group = "diffview" },
  { "<leader> dc", ":DiffviewClose<cr>",         desc = "close" },
  { "<leader> df", ":DiffviewFileHistory<cr>",   desc = "file history" },
  { "<leader> dF", ":DiffviewFileHistory %<cr>", desc = "file history %" },
  { "<leader> do", ":DiffviewOpen<cr>",          desc = "open" },

  { "<leader> j",  group = "join" },
  {
    "<leader> jj",
    function()
      tj().join()
    end,
    desc = "join",
  },
  {
    "<leader> jJ",
    function()
      tj().join({ split = { recursive = true } })
    end,
    desc = "recursive join",
  },
  {
    "<leader> js",
    function()
      tj().split()
    end,
    desc = "split",
  },
  {
    "<leader> jS",
    function()
      tj().split({ split = { recursive = true } })
    end,
    desc = "recursive split",
  },
  {
    "<leader> jt",
    function()
      tj().toggle()
    end,
    desc = "toggle",
  },
  {
    "<leader> jT",
    function()
      tj().toggle({ split = { recursive = true } })
    end,
    desc = "recursive toggle",
  },

  { "<leader> l",  group = "lazy" },
  { "<leader> lh", ":Lazy<cr>",            desc = "home" },
  { "<leader> ls", ":Lazy sync<cr>",       desc = "sync" },
  { "<leader> o",  "<cmd>Oil --float<cr>", desc = "edit directory" },
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
    { "<leader> t",   group = "translate" },
    { "<leader> td",  group = "deutsch" },
    { "<leader> tdf", ":Translate DE -output=floating<cr>", desc = "floating" },
    { "<leader> tdg", ":Translate DE -output=register<cr>", desc = "register" },
    { "<leader> tdi", ":Translate DE -output=insert<cr>",   desc = "insert" },
    { "<leader> tdr", ":Translate DE -output=replace<cr>",  desc = "replace" },
    { "<leader> tds", ":Translate DE -output=split<cr>",    desc = "split" },

    { "<leader> te",  group = "english" },
    { "<leader> tef", ":Translate EN -output=floating<cr>", desc = "floating" },
    { "<leader> teg", ":Translate EN -output=register<cr>", desc = "register" },
    { "<leader> tei", ":Translate EN -output=insert<cr>",   desc = "insert" },
    { "<leader> ter", ":Translate EN -output=replace<cr>",  desc = "replace" },
    { "<leader> tes", ":Translate EN -output=split<cr>",    desc = "split" },
  },

  { "<leader>.",  smart_open,            desc = "smart open" },
  {
    "<leader>-",
    function()
      tb().find_files({ hidden = true })
    end,
    desc = "honour ignores",
  },

  { "<leader> ",  group = "plugins" },
  { "<leader>,",  group = "language" },
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
  { "<leader>,g",   group = "go" },
  { "<leader>,ga",  ":GoAlt!<cr>",     desc = "alternative file" },
  { "<leader>,gc",  ":GoCoverage<cr>", desc = "coverage" },

  { "<leader>,gd",  group = "debug" },
  { "<leader>,gds", ":GoDebug<cr>",    desc = "start" },
  { "<leader>,gdt", ":GoDbgStop<cr>",  desc = "stop" },

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
      nt().run.run(file)
    end,
    desc = "all",
  },
  {
    "<leader>,gtf",
    function()
      local file = vim.fn.expand("%")
      print(file)
      nt().run.run(file)
    end,
    desc = "file",
  },
  {
    "<leader>,gto",
    function()
      nt().output.open({ enter = true })
    end,
    desc = "open results",
  },
  {
    "<leader>,gts",
    function()
      nt().summary.toggle()
    end,
    desc = "toggle summary",
  },

  { "<leader>,p",  group = "perl" },
  {
    "<leader>,ps",
    function()
      load_perl_stack_trace()
    end,
    desc = "stack trace to qf",
  },

  { "<leader>f",  group = "telescope" },
  { "<leader>f,", group = "find files" },
  {
    "<leader>f,a",
    function()
      t().find_files({ hidden = true, no_ignore = true })
    end,
    desc = "include ignores",
  },
  {
    "<leader>f,c",
    function()
      t().find_files({
        fd = require("local_defs").fn.common_fd(),
        hidden = true,
      })
    end,
    desc = "common files",
  },
  { "<leader>f,f", ":Telescope frecency workspace=CWD<cr>", desc = "frecency" },
  {
    "<leader>f,g",
    function()
      t().git_files({ hidden = true })
    end,
    desc = "git files",
  },
  {
    "<leader>f,i",
    function()
      t().find_files({ hidden = true })
    end,
    desc = "honour ignores",
  },
  { "<leader>f,s", smart_open,                              desc = "smart open" },

  { "<leader>fa",  vim.lsp.buf.code_action,                 desc = "code action" },
  {
    "<leader>fA",
    function()
      t().find_files({ hidden = true, no_ignore = true })
    end,
    desc = "find all files",
  },
  {
    "<leader>fb",
    function()
      tb().buffers()
    end,
    desc = "buffers",
  },

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

  {
    "<leader>fC",
    function()
      tb().commands()
    end,
    desc = "commands",
  },

  { "<leader>fd",  group = "diagnostics" },
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

  {
    "<leader>fD",
    function()
      tb().lsp_diagnostics()
    end,
    desc = "lsp diagnostics",
  },
  {
    "<leader>fe",
    function()
      tb().resume()
    end,
    mode = { "n", "v" },
    desc = "resume",
  },
  {
    "<leader>ff",
    function()
      tb().builtin()
    end,
    mode = { "n", "v" },
    desc = "builtin",
  },
  {
    "<leader>fE",
    function()
      tb().treesitter()
    end,
    desc = "treesitter",
  },
  {
    "<leader>fg",
    function()
      tb().live_grep()
    end,
    desc = "live grep",
  },
  {
    "<leader>fG",
    function()
      tb().live_grep({
        additional_args = function()
          return { "-w" }
        end,
      })
    end,
    desc = "grep word",
  },
  {
    "<leader>fh",
    function()
      tb().help_tags()
    end,
    desc = "help tags",
  },
  {
    "<leader>fH",
    function()
      tb().highlights()
    end,
    desc = "highlights",
  },

  { "<leader>fi", group = "git" },
  {
    "<leader>fib",
    function()
      tb().git_branches()
    end,
    desc = "branches",
  },
  {
    "<leader>fic",
    function()
      tb().git_commits()
    end,
    desc = "commits",
  },
  {
    "<leader>fif",
    function()
      tb().git_files()
    end,
    desc = "files",
  },
  {
    "<leader>fih",
    function()
      t().extensions.git_file_history.git_file_history()
    end,
    desc = "file history",
  },
  {
    "<leader>fis",
    function()
      tb().git_status()
    end,
    desc = "status",
  },
  {
    "<leader>fit",
    function()
      tb().git_stash()
    end,
    desc = "stash",
  },
  {
    "<leader>fiu",
    function()
      tb().git_commits()
    end,
    desc = "buffer commits",
  },

  {
    "<leader>fj",
    function()
      tb().jumplist()
    end,
    desc = "jump list",
  },
  {
    "<leader>fJ",
    function()
      t().extensions.emoji.emoji()
    end,
    desc = "emoji",
  },
  {
    "<leader>fl",
    function()
      tb().current_buffer_fuzzy_find()
    end,
    desc = "fuzzy find",
  },
  {
    "<leader>fm",
    function()
      tb().keymaps()
    end,
    desc = "mappings",
  },
  {
    "<leader>fM",
    function()
      tb().man_pages()
    end,
    desc = "man pages",
  },
  {
    "<leader>fn",
    function()
      t().extensions.notify.notify()
    end,
    desc = "show notifications",
  },
  {
    "<leader>fo",
    function()
      tb().vim_options()
    end,
    desc = "vim options",
  },
  {
    "<leader>fO",
    function()
      tb().oldfiles()
    end,
    desc = "old files",
  },
  {
    "<leader>fp",
    function()
      t().extensions.neoclip.default()
    end,
    desc = "paste",
  },
  { "<leader>fP", ":UrlView lazy<cr>", desc = "plugins" },
  {
    "<leader>fq",
    function()
      tb().quickfix()
    end,
    desc = "quickfix",
  },
  {
    "<leader>fQ",
    function()
      tb().quickfixhistory()
    end,
    desc = "quickfix history",
  },
  {
    "<leader>fr",
    function()
      tb().lsp_references()
    end,
    desc = "lsp references",
  },
  {
    "<leader>fR",
    function()
      t().extensions.refactoring.refactors()
    end,
    desc = "refactor",
  },
  {
    "<leader>fs",
    function()
      tb().grep_string()
    end,
    mode = { "n", "v" },
    desc = "grep string",
  },
  {
    "<leader>fS",
    function()
      tb().grep_string({ word_match = "-w" })
    end,
    desc = "grep string word",
  },
  {
    "<leader>ft",
    function()
      tb().current_buffer_tags()
    end,
    desc = "local tags",
  },
  {
    "<leader>fT",
    function()
      tb().tags()
    end,
    desc = "tags",
  },
  {
    "<leader>fu",
    function()
      t().extensions.undo.undo()
    end,
    desc = "undo",
  },

  { "<leader>fU",  group = "url" },
  { "<leader>fUu", ":UrlView buffer<cr>",               desc = "yank url" },
  { "<leader>fUU", ":UrlView buffer action=system<cr>", desc = "open url" },
  { "<leader>fUl", ":UrlView lazy<cr>",                 desc = "yank lazy url" },
  { "<leader>fUL", ":UrlView lazy action=system<cr>",   desc = "open lazy url" },
  {
    "<leader>fv",
    function()
      tb().tags({ default_text = vim.fn.expand("<cword>") })
    end,
    desc = "cword tags",
  },
  { "<leader>fx",  ":TodoTelescope<cr>",     desc = "todos" },
  { "<leader>fY",  ":Telescope symbols<cr>", desc = "symbols" },

  { "<leader>fy",  group = "type" },
  { "<leader>fyg", group = "go" },
  {
    "<leader>fygg",
    function()
      tb().live_grep({ type_filter = "go" })
    end,
    desc = "grep",
  },
  {
    "<leader>fygG",
    function()
      tb().live_grep({
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
      tb().grep_string({
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
      tb().grep_string({
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
      tb().live_grep({ type_filter = "perl" })
    end,
    desc = "grep",
  },
  {
    "<leader>fypG",
    function()
      tb().live_grep({
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
      tb().grep_string({
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
      tb().grep_string({
        additional_args = function()
          return { "--type=perl" }
        end,
        word_match = "-w",
      })
    end,
    mode = { "n", "v" },
    desc = "grep string word",
  },
  {
    "<leader>fz",
    function()
      tb().lsp_document_symbols()
    end,
    desc = "lsp symbols",
  },

  { "<leader>g",   group = "git" },
  {
    "<leader>gg",
    function() vim.cmd("tab Git commit") end,
    desc = "commit",
  },
  {
    "<leader>gG",
    function() vim.cmd("tab Git commit --no-verify") end,
    desc = "commit --no-verify",
  },
  {
    "<leader>gp",
    function()
      vim.cmd("Git push")
    end,
    desc = "push",
  },

  { "<leader>gl",  group = "gitlab" },
  {
    "<leader>gla",
    function()
      gl().approve()
    end,
    desc = "approve",
  },

  { "<leader>glA", group = "assignee" },
  {
    "<leader>glAa",
    function()
      gl().add_assignee()
    end,
    desc = "add assignee",
  },
  {
    "<leader>glAd",
    function()
      gl().delete_assignee()
    end,
    desc = "delete assignee",
  },

  {
    "<leader>glc",
    function()
      gl().create_comment()
    end,
    desc = "create comment",
  },
  {
    "<leader>glc",
    function()
      gl().create_multiline_comment()
    end,
    mode = "v",
    desc = "create multiline comment",
  },
  {
    "<leader>gld",
    function()
      gl().toggle_discussions()
    end,
    desc = "toggle discussions",
  },

  { "<leader>gll", group = "label" },
  {
    "<leader>glla",
    function()
      gl().add_label()
    end,
    desc = "add label",
  },
  {
    "<leader>glld",
    function()
      gl().delete_label()
    end,
    desc = "delete label",
  },

  {
    "<leader>glm",
    function()
      gl().move_to_discussion_tree_from_diagnostic()
    end,
    desc = "move to discussion tree from diagnostic",
  },

  { "<leader>glM", group = "MR" },
  {
    "<leader>glMc",
    function()
      gl().create_mr()
    end,
    desc = "create mr",
  },
  {
    "<leader>glMm",
    function()
      gl().merge()
    end,
    desc = "merge",
  },

  {
    "<leader>gln",
    function()
      gl().create_note()
    end,
    desc = "create note",
  },
  {
    "<leader>glo",
    function()
      gl().open_in_browser()
    end,
    desc = "open in browser",
  },
  {
    "<leader>glp",
    function()
      gl().pipeline()
    end,
    desc = "pipeline",
  },
  {
    "<leader>glr",
    function()
      gl().review()
    end,
    desc = "review",
  },

  { "<leader>glR", group = "reviewer" },
  {
    "<leader>glRa",
    function()
      gl().add_reviewer()
    end,
    desc = "add reviewer",
  },
  {
    "<leader>glRd",
    function()
      gl().delete_reviewer()
    end,
    desc = "delete reviewer",
  },

  {
    "<leader>gls",
    function()
      gl().summary()
    end,
    desc = "summary",
  },
  {
    "<leader>glS",
    function()
      gl().create_comment_suggestion()
    end,
    mode = "v",
    desc = "create comment suggestion",
  },
  {
    "<leader>glV",
    function()
      gl().revoke()
    end,
    desc = "revoke",
  },

  { "<leader>h",   group = "hunk" },
  {
    "<leader>hb",
    function()
      gs().blame_line({ full = true })
    end,
    desc = "blame",
  },
  {
    "<leader>hd",
    function()
      gs().diffthis()
    end,
    desc = "diff hunk",
  },
  {
    "<leader>hD",
    function()
      gs().diffthis("~")
    end,
    desc = "diff",
  },
  {
    "<leader>hi",
    function()
      gs().preview_hunk_inline()
    end,
    desc = "preview hunk inline",
  },
  {
    "<leader>hp",
    function()
      gs().preview_hunk()
    end,
    desc = "preview hunk",
  },
  {
    "<leader>hr",
    function()
      gs().reset_hunk()
    end,
    desc = "reset hunk",
  },
  {
    "<leader>hr",
    function()
      gs().reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end,
    mode = "v",
    desc = "reset hunk",
  },
  {
    "<leader>hR",
    function()
      gs().reset_buffer()
    end,
    desc = "reset_buffer",
  },
  {
    "<leader>hs",
    function()
      gs().stage_hunk()
    end,
    desc = "stage hunk",
  },
  {
    "<leader>hs",
    function()
      gs().stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end,
    mode = "v",
    desc = "stage hunk",
  },
  {
    "<leader>hS",
    function()
      gs().stage_buffer()
    end,
    desc = "stage buffer",
  },
  {
    "<leader>hu",
    function()
      gs().undo_stage_hunk()
    end,
    desc = "unstage hunk",
  },
  {
    "<leader>hx",
    function()
      gs().show()
    end,
    desc = "show index",
  },
  {
    "ih",
    function()
      gs().select_hunk()
    end,
    mode = { "o", "x" },
    desc = "select hunk",
  },

  { "<leader>k", mode = { "n", "v" }, desc = "highlight word" },
  { "<leader>K", mode = { "n", "v" }, desc = "unhighlight words" },
  {
    "<leader>l",
    [[:let @/ = ""<bar>:call UncolorAllWords()<cr>]],
    desc = "unhighlight all",
  },
  {
    "<leader>m",
    function()
      tb().git_status()
    end,
    desc = "find git changes",
  },
  { "<leader>n",  ":NewFile<cr>", desc = "new file template" },

  { "<leader>q",   group = "quote" },
  { "<leader>qA",  [[csQJ]],  noremap = false, desc = "-> q( )" },
  { "<leader>qa",  [[csQF]],  noremap = false, desc = "-> qq( )" },
  { "<leader>qb",  [[csQ`]],  noremap = false, desc = "-> backtick" },
  { "<leader>qdb", [[ds`]],   noremap = false, desc = "delete backtick" },
  { "<leader>qdd", [[ds"]],   noremap = false, desc = "delete double" },
  { "<leader>qds", [[ds']],   noremap = false, desc = "delete single" },
  { "<leader>qib", [[ysiw`]], noremap = false, desc = "insert backtick" },
  { "<leader>qid", [[ysiw"]], noremap = false, desc = "insert double" },
  { "<leader>qis", [[ysiw']], noremap = false, desc = "insert single" },
  { "<leader>qQ",  [[csQ']],  noremap = false, desc = "-> single" },
  { "<leader>qq",  [[csQ"]],  noremap = false, desc = "-> double" },
  { "<leader>qr",  [[dsQ]],   noremap = false, desc = "delete quotes" },
  { "<leader>qw",  [[csQA]],  noremap = false, desc = "-> qw( )" },
  {
    "<leader>qi(",
    [[ysiw(]],
    noremap = false,
    desc = "insert parentheses with space",
  },
  {
    "<leader>qi)",
    [[ysiw)]],
    noremap = false,
    desc = "insert parentheses without space",
  },
  {
    "<leader>qi{",
    [[ysiw{]],
    noremap = false,
    desc = "insert braces with space",
  },
  {
    "<leader>qi}",
    [[ysiw}]],
    noremap = false,
    desc = "insert braces without space",
  },

  { "<leader>r",   group = "session & git" },
  {
    "<leader>rr",
    ":mksess! /tmp/tmp_session.vim<cr>:xa<cr>",
    desc = "save session and exit",
  },

  { "<leader>s",   group = "spell" },
  { "<leader>sd",  ":setlocal spell spelllang=de_ch<cr>",     desc = "Deutsch" },
  { "<leader>se",  ":setlocal spell spelllang=en_gb<cr>",     desc = "English" },
  { "<leader>so",  ":set nospell<cr>",                        desc = "off" },

  { "<leader>t",   group = "toggle" },
  { "<leader>t ",  ":Yazi toggle<cr>",                        desc = "yazi" },
  { "<leader>tc",  ":TSContextToggle<cr>",                    desc = "context" },

  { "<leader>tg",  group = "git" },
  { "<leader>tgb", ":Gitsigns toggle_current_line_blame<cr>", desc = "blame" },
  { "<leader>tgd", ":Gitsigns toggle_deleted<cr>",            desc = "deleted" },
  { "<leader>tgi", ":Gitsigns toggle_word_diff<cr>",          desc = "diff" },
  { "<leader>tgl", ":Gitsigns toggle_linehl<cr>",             desc = "line hl" },
  { "<leader>tgn", ":Gitsigns toggle_numhl<cr>",              desc = "num hl" },
  { "<leader>tgs", ":Gitsigns toggle_signs<cr>",              desc = "signs" },

  { "<leader>th",  ":TSBufToggle highlight<cr>",              desc = "treesitter highlight" },

  { "<leader>tm",  group = "markdown" },
  { "<leader>tmp", ":MarkdownPreviewToggle<cr>",              desc = "preview" },
  { "<leader>tmv", ":Markview toggle<cr>",                    desc = "view" },
  { "<leader>tms", ":Markview splitToggle<cr>",               desc = "split" },

  { "<leader>to",  ":Outline<cr>",                            desc = "symbols" },
  {
    "<leader>ts",
    function()
      require("sidebar-nvim").toggle()
    end,
    desc = "sidebar",
  },
  { "<leader>tt", ":NvimTreeToggle<cr>",   desc = "tree" },
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
        bd().digraphs("insert")
      end,
      desc = "digraph",
    },
    -- Smart scroll mappings that accept completion first if popup is visible
    {
      "<C-e>",
      function()
        if vim.fn.pumvisible() ~= 0 then
          return "<C-y><C-e>" -- Accept completion then scroll down
        else
          return "<Esc>a<C-e>"
        end
      end,
      expr = true,
      desc = "smart scroll down",
    },
    {
      "<C-y>",
      function()
        if vim.fn.pumvisible() ~= 0 then
          return "<C-y><C-y>" -- Accept completion then scroll up
        else
          return "<C-y>"
        end
      end,
      expr = true,
      desc = "smart scroll up",
    },
  },

  {
    mode = "c",
    -- Write file with sudo when permission denied
    {
      "w!!",
      function()
        return "execute 'silent! write !sudo tee % >/dev/null' | edit!"
      end,
      expr = true,
      desc = "sudo write",
    },
  },

  -- EasyAlign mappings
  {
    "gA",
    "<Plug>(EasyAlign)",
    mode = { "n", "x" },
    noremap = false,
    desc = "easy align",
  },
  {
    "<Enter>",
    "<Plug>(EasyAlign)",
    mode = "v",
    noremap = false,
    desc = "easy align",
  },

  -- Move block mappings
  {
    "<C-S-Up>",
    "<Plug>MoveBlockUp",
    mode = "v",
    noremap = false,
    desc = "move block up",
  },
  {
    "<C-S-Down>",
    "<Plug>MoveBlockDown",
    mode = "v",
    noremap = false,
    desc = "move block down",
  },
  {
    "<C-S-Left>",
    "<Plug>MoveBlockLeft",
    mode = "v",
    noremap = false,
    desc = "move block left",
  },
  {
    "<C-S-Right>",
    "<Plug>MoveBlockRight",
    mode = "v",
    noremap = false,
    desc = "move block right",
  },
})


-- Insert mode abbreviation
vim.keymap.set("ia", ",,", "=>", { desc = "arrow abbreviation" })

-- NewFile function in Lua
local function new_file(args)
  local file_type = args.args or ""
  local current_file = vim.fn.expand("%")
  local path = vim.o.path

  -- Execute the file_template command
  local cmd = string.format("file_template -path %s %s %s", path, current_file, file_type)
  vim.cmd("r! " .. cmd)

  -- Remove the first line (which would be empty after the read)
  vim.cmd("normal! ggdd")

  -- Search for the implementation comment
  local ok = pcall(vim.cmd, "/^[ \\t]*[#] *implementation/")
  if not ok then
    -- If search fails, just go to the beginning
    vim.cmd("normal! gg")
  end

  -- Write the file
  vim.cmd("write")
end

-- Create the NewFile command
vim.api.nvim_create_user_command("NewFile", new_file, {
  nargs = "?",
  desc = "Create new file from template"
})

-- Shell commands
vim.api.nvim_create_user_command("Xshell", function(args)
  vim.cmd("10new")
  vim.cmd("Shell " .. args.args)
  vim.cmd("wincmd p")
end, {
  nargs = "+",
  desc = "Execute shell command in horizontal split"
})

vim.api.nvim_create_user_command("Sshell", function(args)
  vim.cmd("vnew")
  vim.cmd("Shell " .. args.args)
  vim.cmd("wincmd p")
end, {
  nargs = "+",
  desc = "Execute shell command in vertical split"
})

