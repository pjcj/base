local M = {}

-- Custom on_attach function
local on_attach = function(client, bufnr)
  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlightProvider then
    local group = vim.api.nvim_create_augroup(
      "lsp_document_highlight_" .. bufnr,
      { clear = true }
    )

    vim.api.nvim_create_autocmd("CursorHold", {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end

  if client.server_capabilities.documentSymbolProvider then
    local navic = require("nvim-navic")
    if not navic.is_available(bufnr) then navic.attach(client, bufnr) end
  end
end

-- Register server configurations using vim.lsp.config
vim.lsp.config.bashls = {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh" },
  root_markers = { ".git" },
}

vim.lsp.config.ctags_lsp = {
  cmd = { "ctags-lsp" },
  filetypes = { "*" }, -- Works with all file types
  root_markers = { ".git", "tags", ".tags" },
}

vim.lsp.config.clangd = {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    ".git",
  },
}

vim.lsp.config.cssls = {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_markers = { "package.json", ".git" },
}

vim.lsp.config.dockerls = {
  cmd = { "docker-langserver", "--stdio" },
  filetypes = { "dockerfile" },
  root_markers = { "Dockerfile", ".git" },
}

vim.lsp.config.eslint = {
  cmd = { "vscode-eslint-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
    "svelte",
    "astro",
  },
  root_markers = {
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json",
    "eslint.config.js",
    "package.json",
    ".git",
  },
  -- The server expects the settings VS Code sends and crashes on
  -- textDocument/diagnostic without them ("path" must be of type string).
  settings = {
    validate = "on",
    useESLintClass = false,
    experimental = {},
    codeActionOnSave = {
      enable = false,
      mode = "all",
    },
    format = true,
    quiet = false,
    onIgnoredFiles = "off",
    rulesCustomizations = {},
    run = "onType",
    problems = {
      shortenToSingleLine = false,
    },
    nodePath = "",
    workingDirectory = { mode = "auto" },
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = "separateLine",
      },
      showDocumentation = {
        enable = true,
      },
    },
  },
  before_init = function(_, config)
    local root_dir = config.root_dir
    if root_dir then
      config.settings = config.settings or {}
      config.settings.workspaceFolder = {
        uri = root_dir,
        name = vim.fn.fnamemodify(root_dir, ":t"),
      }
    end
  end,
}

vim.lsp.config.golangci_lint_ls = {
  cmd = { "golangci-lint-langserver" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = {
    ".golangci.yml",
    ".golangci.yaml",
    ".golangci.toml",
    ".golangci.json",
    "go.mod",
    ".git",
  },
}

vim.lsp.config.gopls = {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.mod", "go.work", ".git" },
  settings = {
    gopls = {
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}

vim.lsp.config.html = {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  root_markers = { ".git" },
}

vim.lsp.config.jsonls = {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
}

vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  },
  init_options = { hostInfo = "neovim" },
  settings = {},
}

vim.lsp.config.perlnavigator = {
  cmd = { "perlnavigator" },
  filetypes = { "perl" },
  root_markers = { ".git" },
  settings = {
    perlnavigator = {
      perlPath = os.getenv("LINT_PERL_PATH") or "perl",
      includePaths = (function()
        local ok, local_defs = pcall(require, "local_defs")
        return ok and local_defs.fn.perl_inc_dirs() or {}
      end)(),

      perlcriticEnabled = vim.fn.filereadable(".perlcriticrc") == 1,
      perlcriticProfile = ".perlcriticrc",
      perlcriticMessageFormat = "%m - %e",

      perlimportsProfile = ".perlimports.toml",
      perlimportsLintEnabled = vim.fn.filereadable(".perlimports.toml") == 1,
      perlimportsTidyEnabled = vim.fn.filereadable(".perlimports.toml") == 1,

      enableWarnings = false,
    },
  },
}

vim.lsp.config.perl_lsp = {
  cmd = { "perllsp", "--stdio" },
  filetypes = { "perl" },
  root_markers = {
    ".perl-lsp.toml",
    "Makefile.PL",
    "Build.PL",
    "cpanfile",
    "dist.ini",
    ".git",
  },
  -- perllsp is navigation-only here.  Its diagnostics are too noisy and it
  -- delivers them via several paths with inconsistent sources ("perl-lsp" on
  -- pull, "perl" on push), so drop them at the client with no-op handlers
  -- rather than trying to match on source.  perlcritic is run via nvim-lint.
  handlers = {
    ["textDocument/publishDiagnostics"] = function() end,
    ["textDocument/diagnostic"] = function() end,
  },
  settings = {
    perl = {
      workspace = {
        perlPath = os.getenv("LINT_PERL_PATH") or "perl",
        includePaths = (function()
          local ok, local_defs = pcall(require, "local_defs")
          return ok and local_defs.fn.perl_inc_dirs() or {}
        end)(),
        -- Probe the interpreter's @INC so installed modules resolve, as
        -- perlnavigator does; without this perl-lsp flags them as missing.
        useSystemInc = true,
      },
      -- Perl formatting is handled by conform, which falls back to an LSP
      -- formatter only as a last resort.  This server is navigation-only, so
      -- its own formatting engine stays off and that fallback is left to any
      -- other formatting-capable server.
      formatting = {
        engine = "off",
      },
    },
  },
  -- perl-lsp applies editor config reliably from didChangeConfiguration, but its
  -- workspace/configuration pull can miss folders and fall back to defaults, so
  -- push the settings on init.  Enable perlcritic only when the project root has
  -- a .perlcriticrc, resolved from the client root rather than the startup cwd.
  on_init = function(client)
    -- perllsp is navigation-only here: all its diagnostics are suppressed and
    -- perlcritic is run via nvim-lint.  It delivers diagnostics by pull, so drop
    -- the capability to stop nvim requesting them at all.
    client.server_capabilities.diagnosticProvider = nil
    client:notify(
      "workspace/didChangeConfiguration",
      { settings = client.settings }
    )
  end,
}

-- tree-sitter-perl/perl-lsp (Veesh) - diagnostics are minimal and opt-in by
-- default, so no settings block is needed for the quiet baseline.
vim.lsp.config.perl_lsp_ts = {
  cmd = { "perl-lsp" },
  filetypes = { "perl" },
  root_markers = {
    "cpanfile",
    "Makefile.PL",
    "Build.PL",
    "dist.ini",
    ".git",
  },
}

vim.lsp.config.sqlls = {
  cmd = { "sql-language-server", "up", "--method", "stdio" },
  filetypes = { "sql", "mysql" },
  root_markers = { ".git" },
  settings = {
    sqlLanguageServer = {
      lint = {
        --  see https://github.com/joe-re/sql-language-server/tree/release/packages/sqlint#configuration
        rules = { -- duplicates .sqlintrc.json - only one is actually needed
          ["align-column-to-the-first"] = "error",
          ["align-where-clause-to-the-first"] = "error",
          ["column-new-line"] = "error",
          ["linebreak-after-clause-keyword"] = 1,
          ["require-as-to-rename-column"] = "off",
          ["reserved-word-case"] = { 1, "lower" },
          ["space-surrounding-operators"] = "error",
          ["where-clause-new-line"] = 1,
        },
      },
    },
  },
}

vim.lsp.config.svelte = {
  cmd = { "svelteserver", "--stdio" },
  filetypes = { "svelte" },
  root_markers = { "package.json", ".git" },
}

vim.lsp.config.taplo = {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  root_markers = { ".git" },
}

vim.lsp.config.typos_lsp = {
  cmd = { "typos-lsp" },
  -- no filetypes = attach to all filetypes
  root_markers = {
    "typos.toml",
    "_typos.toml",
    ".typos.toml",
    ".git",
  },
  settings = {},
}

vim.lsp.config.vtsls = {
  cmd = { "vtsls", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
}

vim.lsp.config.yamlls = {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose" },
  root_markers = { ".git" },
  settings = {
    yaml = {
      format = {
        enable = true,
        bracketSpacing = true,
        singleQuote = false,
      },
      customTags = { "!reference sequence" },
      keyOrdering = false,
      schemaStore = {
        enable = true,
      },
      validate = true,
      completion = true,
    },
  },
}

-- Setup function
local function setup_servers()
  -- setup_servers runs before setup.lua, so default the active Perl server here
  -- too.  A nil entry would truncate the lsps list and drop every server after
  -- it.
  vim.g.perl_lsp_server = vim.g.perl_lsp_server or "perl_lsp"

  require("mason").setup({
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  })

  local lsps = {
    "bashls",
    "ctags_lsp",
    "cssls",
    "dockerls",
    "eslint",
    "golangci_lint_ls",
    "gopls",
    "html",
    "jsonls",
    vim.g.perl_lsp_server,
    -- "sqlls", -- broken with Node.js v25 (SlowBuffer removed)
    "svelte",
    "typos_lsp",
    "vtsls",
    "yamlls",
  }

  local is_freebsd = vim.uv.os_uname().sysname == "FreeBSD"
  if not is_freebsd then
    table.insert(lsps, "clangd")
    table.insert(lsps, "lua_ls")
    table.insert(lsps, "taplo")
  end

  for _, server in ipairs(lsps) do
    local config = vim.lsp.config[server]
    config.on_attach = on_attach
  end

  -- Enable all servers
  vim.lsp.enable(lsps)

  -- Add LspAttach autocmd to ensure on_attach logic runs
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local bufnr = args.buf
      on_attach(client, bufnr)
    end,
  })

  -- Diagnostic configuration
  -- Note: virtual_text disabled to let tiny-inline-diagnostic handle display
  vim.diagnostic.config({
    virtual_text = false,
    float = {
      source = true,
      border = "rounded",
    },
    severity_sort = true,
    underline = true,
  })

  -- Configure borders for LSP floating windows
  -- Note: In Neovim v0.11+, individual border configuration is handled
  -- through vim.diagnostic.config() above for diagnostic floats.
  -- Other LSP floating windows (hover, signature help) use system defaults.
end

M.setup_servers = setup_servers

-- Rotate through the Perl LSP servers, skipping any whose binary is absent:
--   perlnavigator -> perl_lsp (EffortlessMetrics) -> perl_lsp_ts (Veesh)
local perl_lsp_servers = { "perlnavigator", "perl_lsp", "perl_lsp_ts" }

local function cycle_perl_lsp()
  local current = vim.g.perl_lsp_server
  local start = 1
  for i, name in ipairs(perl_lsp_servers) do
    if name == current then
      start = i
      break
    end
  end

  local n = #perl_lsp_servers
  for step = 1, n do
    local new = perl_lsp_servers[(start - 1 + step) % n + 1]
    if vim.fn.executable(vim.lsp.config[new].cmd[1]) == 1 then
      vim.lsp.enable(current, false)
      -- enable(false) stops future attaches but leaves the running client, so
      -- stop it explicitly to fully switch over.
      for _, c in ipairs(vim.lsp.get_clients({ name = current })) do
        c:stop(true)
      end
      vim.g.perl_lsp_server = new
      vim.lsp.config[new].on_attach = on_attach
      vim.lsp.enable(new)
      -- Let nvim-lint refresh the perl linters for the new server (perlcritic
      -- runs only under perl_lsp, so it must be re-run or cleared on a switch).
      vim.api.nvim_exec_autocmds("User", { pattern = "PerlLspChanged" })
      vim.notify("Perl LSP: " .. new, vim.log.levels.INFO)
      return
    end
  end

  vim.notify("No other Perl LSP server available", vim.log.levels.WARN)
end

vim.api.nvim_create_user_command(
  "CyclePerlLsp",
  cycle_perl_lsp,
  { desc = "Rotate between PerlNavigator, perl_lsp and perl_lsp_ts" }
)

-- Diagnostic filtering - optimised single-pass in-place filter
local function filter(arr, func)
  local j = 0
  for i = 1, #arr do
    if func(arr[i], i) then
      j = j + 1
      arr[j] = arr[i]
    end
  end
  -- Clear remaining elements
  for i = j + 1, #arr do
    arr[i] = nil
  end
end

local function filter_diagnostics(diagnostic)
  local source = diagnostic.source
  local message = diagnostic.message

  -- Early return for non-Perl LSP sources
  if
    source ~= "perlnavigator"
    and source ~= "perl_lsp"
    and source ~= "perl-lsp"
  then
    -- Special case for bash-language-server
    if
      source == "bash-language-server"
      and message:find("includeAllWorkspaceSymbols", 1, true)
    then
      return false
    end
    return true
  end

  -- Perlnavigator-specific filters
  -- Using plain string search (4th parameter = true) for better performance
  if message:find("Useless use of a constant", 1, true) then return false end

  -- Check for subroutine redefined (both conditions must be true)
  if
    message:find("Subroutine", 1, true)
    and message:find("redefined at", 1, true)
  then
    return false
  end

  -- Devel::Cover false positive
  if
    message:find(
      "Undefined subroutine &Devel::Cover::set_first_init_and_end called",
      1,
      true
    )
  then
    return false
  end

  -- Veesh perl-lsp: unresolved-method and unresolved-function fire on dispatch
  -- and calls it cannot resolve statically, so drop both categories.
  if
    source == "perl-lsp"
    and (
      diagnostic.code == "unresolved-method"
      or diagnostic.code == "unresolved-function"
    )
  then
    return false
  end

  return true
end

-- Filter push diagnostics (perlnavigator, perl_lsp_ts) in the publishDiagnostics
-- handler, on the raw LSP data before conversion.  EM perllsp delivers via pull
-- and is suppressed by disabling its diagnostics in on_init, so it need not be
-- filtered here.
local orig_diagnostic_handler =
  vim.lsp.handlers["textDocument/publishDiagnostics"]
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(
  err,
  result,
  ctx,
  config
)
  if result and result.diagnostics then
    filter(result.diagnostics, filter_diagnostics)
  end
  return orig_diagnostic_handler(err, result, ctx, config)
end

return M
