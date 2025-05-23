local M = {}

-- How much of this is default and can be deleted?
-- stylua: ignore start
local lsp_sig_cfg = {
  debug                          = false,                                           -- set to true to enable debug logging
  log_path                       = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
                                                                                    -- default is  ~/.cache/nvim/lsp_signature.log
  verbose                        = false,                                           -- show debug line number
  bind                           = true,                                            -- This is mandatory, otherwise border config won't get registered.
                                                                                    -- If you want to hook lspsaga or other signature handler, pls set to false
  doc_lines                      = 10,                                              -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
                                                                                    -- set to 0 if you DO NOT want any API comments be shown
                                                                                    -- This setting only take effect in insert mode, it does not affect signature help in normal
                                                                                    -- mode, 10 by default

  floating_window                = true,                                            -- show hint in a floating window, set to false for virtual text only mode
  floating_window_above_cur_line = true,                                            -- try to place the floating above the current line when possible Note:
                                                                                    -- will set to true when fully tested, set to false will use whichever side has more space
                                                                                    -- this setting will be helpful if you do not want the PUM and floating win overlap

  floating_window_off_x          = 0,                                               -- adjust float windows x position.
  floating_window_off_y          = -4,                                              -- adjust float windows y position.
  fix_pos                        = false,                                           -- set to true, the floating window will not auto-close until finish all parameters
  hint_enable                    = true,                                            -- virtual hint enable
  hint_prefix                    = "🐼 ",                                           -- Panda for parameter
  hint_scheme                    = "String",
  hi_parameter                   = "LspSignatureActiveParameter",                   -- how your parameter will be highlight
  max_height                     = 12,                                              -- max height of signature floating_window, if content is more than max_height, you can scroll down
                                                                                    -- to view the hiding contents
  max_width                      = 120,                                             -- max_width of signature floating_window, line will be wrapped if exceed max_width
  handler_opts                   = {
    border                       =
    "rounded"                                                                       -- double, rounded, single, shadow, none
  },
  always_trigger                 = false,                                           -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58
  auto_close_after               = nil,                                             -- autoclose signature float win after x sec, disabled if nil.
  extra_trigger_chars            = {},                                              -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
  zindex                         = 200,                                             -- by default it will be on top of all floating windows, set to <= 50 send it to bottom
  padding                        = '',                                              -- character to pad on left and right of signature can be ' ', or '|'  etc
  transparency                   = nil,                                             -- disabled by default, allow floating win transparent value 1~100
  shadow_blend                   = 36,                                              -- if you using shadow as border use this set the opacity
  shadow_guibg                   = 'Black',                                         -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
  timer_interval                 = 200,                                             -- default timer check interval set to lower value if you want to reduce latency
  toggle_key                     = nil                                              -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
}
-- stylua: ignore end

-- recommended:
-- require'lsp_signature'.setup(cfg) -- no need to specify bufnr if you don't use toggle_key

-- You can also do this inside lsp on_attach
-- note: on_attach deprecated
-- require'lsp_signature'.on_attach(cfg, bufnr) -- no need to specify bufnr if you don't use toggle_key

-- config that activates keymaps and enables snippet support
-- local function make_config()
--   local capabilities = vim.lsp.protocol.make_client_capabilities()
--   capabilities.textDocument.completion.completionItem.snippetSupport = true
--   return {
--     -- enable snippet support
--     capabilities = capabilities,
--     -- map buffer local keybindings when the language server attaches
--     on_attach = on_attach,
--   }
-- end

local navic = require("nvim-navic")
local on_attach = function(client, bufnr)
  -- print("attach", client.name)

  local function buf_set_option(option, value)
    vim.bo[bufnr][option] = value
  end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- set autocommands conditional on server_capabilities
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
    navic.attach(client, bufnr)
  end

  require("lsp_signature").on_attach(lsp_sig_cfg, bufnr)
end

-- configure lua language server for neovim development
local lua_settings = {
  Lua = {
    runtime = {
      -- LuaJIT in the case of Neovim
      version = "LuaJIT",
      path = vim.split(package.path, ";"),
    },
    diagnostics = {
      -- Get the language server to recognise the `vim` global
      globals = { "vim" },
    },
    workspace = {
      -- Make the server aware of Neovim runtime files
      library = {
        [vim.fn.expand("$VIMRUNTIME/lua")] = true,
        [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
      },
    },
  },
}

-- lsp-install
local function setup_servers()
  local lspconfig = require("lspconfig")

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

  local is_freebsd = (io.popen("uname"):read() == "FreeBSD")
  if not is_freebsd then
    table.insert(lsps, "clangd")
    table.insert(lsps, "lua_ls")
    table.insert(lsps, "taplo")
  end

  require("mason-lspconfig").setup({
    ensure_installed = lsps,
    automatic_enable = false,
  })

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  local conf = {
    capabilities = capabilities,
    on_attach = on_attach,
  }

  lspconfig.bashls.setup({
    filetypes = { "sh", "bash", "zsh" },
    capabilities = capabilities,
    on_attach = on_attach,
  })
  lspconfig.clangd.setup(conf)
  lspconfig.cssls.setup(conf)
  lspconfig.golangci_lint_ls.setup(conf)
  lspconfig.html.setup(conf)
  lspconfig.sqlls.setup(conf)

  lspconfig.gopls.setup({
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
    capabilities = capabilities,
    on_attach = on_attach,
  })

  lspconfig.perlnavigator.setup({
    settings = {
      perlnavigator = {
        perlPath = os.getenv("LINT_PERL_PATH") or "perl",
        includePaths = require("local_defs").fn.perl_inc_dirs(),

        perlcriticEnabled = vim.fn.filereadable(".perlcriticrc"),
        perlcriticProfile = ".perlcriticrc",

        perlimportsProfile = ".perlimports.toml",
        perlimportsLintEnabled = vim.fn.filereadable(".perlimports.toml"),
        perlimportsTidyEnabled = vim.fn.filereadable(".perlimports.toml"),

        enableWarnings = false,
      },
    },
    debounce_text_changes = 5000, -- milliseconds
    capabilities = capabilities,
    on_attach = on_attach,
  })

  lspconfig.yamlls.setup({
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
    capabilities = capabilities,
    on_attach = on_attach,
  })

  if not is_freebsd then
    lspconfig.clangd.setup(conf)
    lspconfig.taplo.setup(conf)
    lspconfig.lua_ls.setup({
      init_options = { hostInfo = "neovim" },
      settings = lua_settings,
      capabilities = capabilities,
      on_attach = on_attach,
    })
  end

  vim.diagnostic.config({
    virtual_text = { prefix = "●" },
    float = { source = true },
    severity_sort = true,
    underline = true,
  })

  local border = "rounded"
  local lspconfig_window = require("lspconfig.ui.windows")
  local old_defaults = lspconfig_window.default_opts
  function lspconfig_window.default_opts(opts)
    local win_opts = old_defaults(opts)
    win_opts.border = border
    return win_opts
  end

  local orig_open_floating_preview = vim.lsp.util.open_floating_preview
  local new_open_floating_preview = function(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or border
    return orig_open_floating_preview(contents, syntax, opts, ...)
  end
  vim.lsp.util.open_floating_preview = new_open_floating_preview

  vim.fn.sign_define("LspDiagnosticsSignError", { text = "E" })
  vim.fn.sign_define("LspDiagnosticsSignWarning", { text = "W" })
  vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "I" })
  vim.fn.sign_define("LspDiagnosticsSignHint", { text = "H" })

  -- vim.lsp.handlers['window/showMessage'] = function(_, result, ctx)
  --   local client = vim.lsp.get_client_by_id(ctx.client_id)
  --   local lvl = ({ 'ERROR', 'WARN', 'INFO', 'DEBUG' })[result.type]
  --   vim.notify({ result.message }, lvl, {
  --     title = 'LSP | ' .. client.name,
  --     timeout = 10000,
  --     keep = function()
  --       return lvl == 'ERROR' or lvl == 'WARN'
  --     end,
  --   })
  -- end
end

M.setup_servers = setup_servers

-- -- table from lsp severity to vim severity.
-- local severity = {
--   "error",
--   "warn",
--   "info",
--   "info", -- map both hint and info to info?
-- }
-- vim.lsp.handlers["window/showMessage"] = function(err, method, params, client_id)
--   print(method.message)
--   vim.notify(method.message, severity[params.type])
-- end

local function filter(arr, func)
  -- Filter in place
  -- https://stackoverflow.com/questions/49709998/how-to-filter-a-lua-array-inplace
  local new_index = 1
  local size_orig = #arr
  for old_index, v in ipairs(arr) do
    if func(v, old_index) then
      arr[new_index] = v
      new_index = new_index + 1
    end
  end
  for i = new_index, size_orig do
    arr[i] = nil
  end
end

local function filter_diagnostics(diagnostic)
  if
    diagnostic.source == "bash-language-server"
    and string.match(diagnostic.message, "includeAllWorkspaceSymbols")
  then
    return false
  end

  if diagnostic.source ~= "perlnavigator" then
    return true
  end

  -- Ignore quotes at the end of the file
  if string.match(diagnostic.message, "Useless use of a constant") then
    return false
  end

  -- Ignore false positives of subroutine redefined
  if
    string.match(diagnostic.message, "Subroutine")
    and string.match(diagnostic.message, "redefined at")
  then
    return false
  end

  -- Ignore false positive in CHECK in Devel::Cover
  if
    string.match(
      diagnostic.message,
      "Undefined subroutine &Devel::Cover::set_first_init_and_end called"
    )
  then
    return false
  end

  return true
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(a, params, ctx)
  filter(params.diagnostics, filter_diagnostics)
  vim.lsp.diagnostic.on_publish_diagnostics(a, params, ctx)
end

return M
