-- keymaps
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) Api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) Api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- mappings
  buf_set_keymap("n", "gD",        "<Cmd>lua vim.lsp.buf.declaration()<CR>",                                Defmap)
  buf_set_keymap("n", "gd",        "<Cmd>lua vim.lsp.buf.definition()<CR>",                                 Defmap)
  buf_set_keymap("n", "gi",        "<cmd>lua vim.lsp.buf.implementation()<CR>",                             Defmap)
  buf_set_keymap("n", "gr",        "<cmd>lua vim.lsp.buf.references()<CR>",                                 Defmap)
  buf_set_keymap("n", "K",         "<Cmd>lua vim.lsp.buf.hover()<CR>",                                      Defmap)
  buf_set_keymap("n", "<C-k>",     "<cmd>lua vim.lsp.buf.signature_help()<CR>",                             Defmap)
  buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>",                       Defmap)
  buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>",                    Defmap)
  buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", Defmap)
  buf_set_keymap("n", "<space>D",  "<cmd>lua vim.lsp.buf.type_definition()<CR>",                            Defmap)
  buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>",                                     Defmap)
  buf_set_keymap("n", "<space>f",  "<cmd>lua vim.diagnostic.open_float()<CR>",                              Defmap)
  buf_set_keymap("n", "<C-up>",    "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>",                           Defmap)
  buf_set_keymap("n", "<C-down>",  "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>",                           Defmap)
  buf_set_keymap("n", "<space>q",  "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>",                         Defmap)
  buf_set_keymap("n", "<space>a",  "<cmd>lua vim.lsp.buf.code_action()<CR>",                                Defmap)
  buf_set_keymap("n", "<space>ci", "<cmd>lua vim.lsp.buf.incoming_calls()<CR>",                             Defmap)
  buf_set_keymap("n", "<space>co", "<cmd>lua vim.lsp.buf.outgoing_calls()<CR>",                             Defmap)

  -- set some keybindings conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", Defmap)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", Defmap)
  end

  -- set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    Exec([[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup end
    ]], false)
  end

  Fn.sign_define("LspDiagnosticsSignError",       { text = "E" })
  Fn.sign_define("LspDiagnosticsSignWarning",     { text = "W" })
  Fn.sign_define("LspDiagnosticsSignInformation", { text = "I" })
  Fn.sign_define("LspDiagnosticsSignHint",        { text = "H" })

  require "lsp_signature".on_attach()
end

local function no_really_fn (params)
  local diagnostics = {}
  -- sources have access to a params object
  -- containing info about the current file and editor state
  for i, line in ipairs(params.content) do
    local col, end_col = line:find("really")
    if col and end_col then
      -- null-ls fills in undefined positions
      -- and converts source diagnostics into the required format
      table.insert(diagnostics, {
        row      = i,
        col      = col,
        end_col  = end_col,
        source   = "no-really",
        message  = "Don't use 'really!'",
        severity = 4,
      })
    end
  end
  return diagnostics
end

local function setup_null_ls ()
  local null_ls = require "null-ls"

  -- null_ls.register({
    -- method    = null_ls.methods.DIAGNOSTICS,
    -- filetypes = { "markdown", "text" },
    -- generator = { fn = no_really_fn },
  -- })

  local b = null_ls.builtins
  local f = b.formatting
  local d = b.diagnostics
  local a = b.code_actions

  local sources = {
    a.proselint,
    f.fixjson,
    f.shellharden,
    f.shfmt,
    f.stylua,
    d.markdownlint,
    d.proselint,
    -- d.selene,
    d.shellcheck,
    d.yamllint,
  }

  null_ls.setup({
    sources = sources,
  })
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
      -- Get the language server to recognize the `vim` global
      globals = { "vim" },
    },
    workspace = {
      -- Make the server aware of Neovim runtime files
      library = {
        [vim.fn.expand("$VIMRUNTIME/lua")] = true,
        [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
      },
    },
  }
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
        vim.lsp.diagnostic.on_publish_diagnostics, {
          virtual_text = true -- enable virtual_text
        }
      ),
    }
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
          "make", "--quiet", "-C", "api", "lint_api_json",
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
