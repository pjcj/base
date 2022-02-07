-- keymaps
local on_attach = function(client, bufnr)
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

  -- stylua: ignore start
  vim.fn.sign_define("LspDiagnosticsSignError",       { text = "E" })
  vim.fn.sign_define("LspDiagnosticsSignWarning",     { text = "W" })
  vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "I" })
  vim.fn.sign_define("LspDiagnosticsSignHint",        { text = "H" })
  -- stylua: ignore end

  require("lsp_signature").on_attach()
end

local null_ls = require "null-ls"
local helpers = require "null-ls.helpers"

local perl_executable = vim.fn.expand "~/g/base/utils/lint_perl"
local perl_diagnostics = {
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { "perl" },
  generator = null_ls.generator {
    command = perl_executable,
    args = { "$FILENAME", "$ROOT", "$FILEEXT", "$TEXT" },
    to_stdin = true,
    from_stderr = true,
    format = "line", --raw, json, or line
    check_exit_code = function(code, stderr)
      local success = code <= 1
      if not success then
        print(stderr)
      end
      return success
    end,
    on_output = helpers.diagnostics.from_patterns {
      {
        pattern = [[(%d+):(.*)]],
        groups = { "row", "message" },
      },
    },
  },
}

local function setup_null_ls()
  null_ls.register(perl_diagnostics)

  local b = null_ls.builtins
  local a = b.code_actions
  local c = b.completion
  local d = b.diagnostics
  local f = b.formatting
  local h = b.hover

  local codespell = {
    "--builtin",
    "clear,rare,informal,usage,names",
    "-L",
    "isnt,master",
    -- isnt       => perl test method
    -- master     => yeah, I know but it's not me
  }

  local sources = {
    a.eslint,
    -- a.gitsigns,
    a.proselint,
    -- a.refactoring,
    a.shellcheck,
    c.spell,
    c.vsnip,
    d.codespell.with { extra_args = codespell },
    d.eslint,
    d.golangci_lint,
    d.hadolint,
    d.jsonlint,
    d.markdownlint,
    d.misspell.with { extra_args = { "-i", "XXXOXXX" } },
    d.proselint,
    d.selene,
    d.shellcheck,
    d.yamllint,
    f.codespell.with { extra_args = codespell },
    f.eslint,
    f.fixjson,
    f.golines,
    -- f.prettier,
    f.shellharden,
    f.shfmt.with { extra_args = { "-i", "2", "-s" } },
    f.stylua,
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

-- config that activates keymaps and enables snippet support
local function make_config()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return {
    -- enable snippet support
    capabilities = capabilities,
    -- map buffer local keybindings when the language server attaches
    on_attach = on_attach,
    handlers = {
      ["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics,
        {
          virtual_text = true, -- enable virtual_text
        }
      ),
    },
  }
end

-- lsp-install
local function setup_servers()
  setup_null_ls()

  local lsp_installer = require "nvim-lsp-installer"
  lsp_installer.on_server_ready(function(server)
    print("configure server", server.name)
    local config = make_config()

    if server.name == "sumneko_lua" then
      config.settings = lua_settings
    end
    if server.name == "golangci_lint_ls" then
      config.init_options = {
        command = {
          -- "golangci-lint", "run", "--out-format", "json",
          "make",
          "--quiet",
          "-C",
          "api",
          "lint_api_json",
        },
      }
    end

    -- This setup() function is exactly the same as lspconfig's setup function
    -- (:help lspconfig-quickstart)
    server:setup(config)
    vim.cmd [[ do User LspAttachBuffers ]]
  end)

  -- local lspconfig = require "lspconfig"
  -- local configs = require "lspconfig/configs"
  -- local gconfig = make_config()
  -- gconfig["cmd"] = { "golangci-lint-langserver" }
  -- gconfig["root_dir"] = lspconfig.util.root_pattern(".git", "go.mod")
  -- gconfig["init_options"] = {
  --   command = {
  --     -- "golangci-lint", "run", "--out-format", "json",
  --     "make", "--quiet", "-C", "api", "lint_api_json",
  --   },
  -- }
  -- gconfig["filetypes"] = { "go" }
  -- -- configs.golangcilsp.setup(gconfig)
  -- -- configs["golangcilsp"].setup(gconfig)
end

setup_servers()
