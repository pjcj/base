local M = {}

local null_ls = require "null-ls"
local helpers = require "null-ls.helpers"

local perl_diagnostics = {
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { "perl" },
  generator = null_ls.generator {
    command = vim.fn.expand "~/g/base/utils/lint_perl",
    args = { "$FILENAME", "$ROOT", "$FILEEXT" },
    to_stdin = true,
    from_stderr = true,
    format = "json", --raw, json, or line
    check_exit_code = function(code, stderr)
      local success = code <= 1
      if not success then
        print(stderr)
      end
      return success
    end,
    on_output = helpers.diagnostics.from_json({
      attributes = {
        row = "row",
        -- col = "start_column",
        -- end_col = "end_column",
        -- severity = "annotation_level",
        message = "message",
      },
      -- severities = {
      --   helpers.diagnostics.severities["information"],
      --   helpers.diagnostics.severities["warning"],
      --   helpers.diagnostics.severities["error"],
      --   helpers.diagnostics.severities["hint"],
      -- },
    }),
  },
}

local function file_exists(name)
   local f = io.open(name,"r")
   if f ~= nil then
     io.close(f)
     return true
   else
     return false
   end
end

local function setup_null_ls()
  null_ls.register(perl_diagnostics)

  local b = null_ls.builtins
  local a = b.code_actions
  local c = b.completion
  local d = b.diagnostics
  local f = b.formatting
  local h = b.hover

  local codespell = { "--builtin", "clear,rare,informal,usage,names" }

  if file_exists(".codespell") then
    table.insert(codespell, "--ignore-words=.codespell")
  end

  local sources = {
    a.eslint,
    -- a.gitsigns,
    a.proselint,
    -- a.refactoring,
    a.shellcheck,
    -- c.spell,  -- puts funny stuff in completion
    c.vsnip,
    d.codespell.with { extra_args = codespell },
    d.eslint,
    d.hadolint,
    d.jsonlint,
    d.markdownlint,
    d.misspell.with { extra_args = { "-i", "importas" } },
    d.proselint,
    d.selene,
    d.shellcheck,
    -- d.sqlfluff,  -- as soon as it works better
    d.tidy,
    d.yamllint,
    d.zsh,
    -- f.beautysh,  -- not all that useful
    f.codespell.with { extra_args = codespell },
    f.eslint,
    f.fixjson,
    f.mdformat.with { extra_args = { "--number" } },
    -- f.golines,
    -- f.prettier,
    f.shellharden,
    f.shfmt.with { extra_args = { "-i", "2", "-s" } },
    -- f.sqlfluff,
    -- f.stylua,
    f.tidy,
    h.dictionary,
  }

  null_ls.setup {
    sources = sources,
  }
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
        [vim.fn.expand "$VIMRUNTIME/lua"] = true,
        [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
      },
    },
  },
}

-- keymaps etc
local on_attach = function(client, bufnr)
  -- print("attach", client.name)

  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec(
      [[
        augroup lsp_document_highlight
          autocmd! * <buffer>
          autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup end
      ]],
      false
    )
  end

  require("lsp_signature").on_attach()
end

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

-- lsp-install
local function setup_servers()
  setup_null_ls()

  local lsp_installer = require "nvim-lsp-installer"
  local lspconfig = require "lspconfig"

  lsp_installer.setup {
    automatic_installation = {
      exclude = {
        -- "spectral",  -- installed externally
      },
    },
    ui = {
      icons = {
        server_installed = "✓",
        server_pending = "➜",
        server_uninstalled = "✗",
      }
    },
  }

  lspconfig.cssls.setup { on_attach = on_attach }
  lspconfig.golangci_lint_ls.setup { on_attach = on_attach }
  lspconfig.gopls.setup { on_attach = on_attach }
  lspconfig.html.setup { on_attach = on_attach }
  -- lspconfig.spectral.setup { on_attach = on_attach }
  lspconfig.sqls.setup { on_attach = on_attach }
  lspconfig.taplo.setup { on_attach = on_attach }
  lspconfig.yamlls.setup { on_attach = on_attach }
  lspconfig.zk.setup { on_attach = on_attach }

  lspconfig.perlnavigator.setup {
    settings = {
      perlnavigator = {
        includePaths = {
          "lib/perl",
          "web/cgi-bin",
          "lib/perl/pki/lib",
          "lib/perl/ere/lib",
          "lib/perl/pkcs11",
          "test/selenium/dev/lib",
          "etc",

          "perl",
          "t/lilb",
          "../dummy_modules",
        },
        perlcriticEnabled = false,
        enableWarnings = false,
      },
    },
    on_attach = on_attach,
  }

  lspconfig.sumneko_lua.setup {
    init_options = { hostInfo = "neovim" },
    settings = lua_settings,
    on_attach = on_attach,
  }

  lspconfig.tsserver.setup {
    init_options = { hostInfo = "neovim" },
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
      local ts_utils = require "nvim-lsp-ts-utils"
      ts_utils.setup {}
      ts_utils.setup_client(client)
      on_attach(client, bufnr)
    end
  }

  lspconfig.volar.setup {
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
      on_attach(client, bufnr)
    end
  }

  vim.diagnostic.config {
    virtual_text = { prefix = "●" },
    float = {
      source = "always", -- or "if_many"
    },
    severity_sort = true,
  }

  local border = "rounded"
  local lspconfig_window = require "lspconfig.ui.windows"
  local old_defaults = lspconfig_window.default_opts
  function lspconfig_window.default_opts(opts)
    local win_opts = old_defaults(opts)
    win_opts.border = border
    return win_opts
  end

  local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or border
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
  end

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
  if diagnostic.source ~= "perlnavigator" then
    return true
  end

  -- Ignore quotes at the end of the file
  if string.match(diagnostic.message, 'Useless use of a constant') then
    return false
  end

  return true
end

local function custom_on_publish_diagnostics(a, params, client_id, c, config)
  filter(params.diagnostics, filter_diagnostics)
  vim.lsp.diagnostic.on_publish_diagnostics(a, params, client_id, c, config)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  custom_on_publish_diagnostics, {})

return M
