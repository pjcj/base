local M = {}

-- Custom on_attach function
local on_attach = function(client, bufnr)
  -- Set dynamic debounce for perlnavigator based on file size
  if client.name == "perlnavigator" then
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    -- 2ms per line, min 500ms, max 60s
    local debounce = math.max(500, math.min(60000, line_count * 2))
    vim.lsp.config.perlnavigator.debounce_text_changes = debounce
    vim.schedule(
      function()
        vim.notify(
          string.format(
            "perlnavigator debounce: %.1fs (%d lines)",
            debounce / 1000,
            line_count
          ),
          vim.log.levels.INFO
        )
      end
    )
  end

  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.document_highlight then
    local group =
      vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })

    vim.api.nvim_create_autocmd("CursorHold", {
      group = group,
      buffer = 0,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
      group = group,
      buffer = 0,
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

vim.lsp.config.taplo = {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  root_markers = { ".git" },
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
    "perlnavigator",
    "sqlls",
    "yamlls",
  }

  local handle = io.popen("uname")
  local is_freebsd = handle and handle:read() == "FreeBSD"
  if handle then handle:close() end
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

  -- Early return for non-perlnavigator sources
  if source ~= "perlnavigator" then
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

  return true
end

-- Override the default diagnostic handler to filter diagnostics
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
