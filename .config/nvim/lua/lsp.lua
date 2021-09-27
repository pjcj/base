-- keymaps
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) Api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) Api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- mappings
  buf_set_keymap('n', 'gD',        '<Cmd>lua vim.lsp.buf.declaration()<CR>',                                Defmap)
  buf_set_keymap('n', 'gd',        '<Cmd>lua vim.lsp.buf.definition()<CR>',                                 Defmap)
  buf_set_keymap('n', 'K',         '<Cmd>lua vim.lsp.buf.hover()<CR>',                                      Defmap)
  buf_set_keymap('n', 'gi',        '<cmd>lua vim.lsp.buf.implementation()<CR>',                             Defmap)
  buf_set_keymap('n', '<C-k>',     '<cmd>lua vim.lsp.buf.signature_help()<CR>',                             Defmap)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',                       Defmap)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',                    Defmap)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', Defmap)
  buf_set_keymap('n', '<space>D',  '<cmd>lua vim.lsp.buf.type_definition()<CR>',                            Defmap)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>',                                     Defmap)
  buf_set_keymap('n', 'gr',        '<cmd>lua vim.lsp.buf.references()<CR>',                                 Defmap)
  buf_set_keymap('n', '<space>e',  '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',               Defmap)
  buf_set_keymap('n', '[d',        '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>',                           Defmap)
  buf_set_keymap('n', ']d',        '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>',                           Defmap)
  buf_set_keymap('n', '<space>q',  '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>',                         Defmap)
  buf_set_keymap('n', '<space>a',  '<cmd>lua vim.lsp.buf.code_action()<CR>',                                Defmap)

  -- set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", Defmap)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", Defmap)
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
      globals = {"vim"},
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
  require "lspinstall".setup()

  -- get all installed servers
  local servers = require "lspinstall".installed_servers()

  for _, server in pairs(servers) do
    local config = make_config()

    -- language specific config
    if server == "lua" then
      config.settings = lua_settings
    end

    require "lspconfig"[server].setup(config)
  end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to
-- restart neovim
require "lspinstall".post_install_hook = function ()
  if #(Api.nvim_list_uis()) == 0 then
    Cmd("quitall")  -- this triggers the FileType autocmd that starts the server
  end
  setup_servers() -- reload installed servers
  Cmd("bufdo e")  -- this triggers the FileType autocmd that starts the server
end

-- golangci-lint-langserver support (doesn't seem to work right now)
-- see https://github.com/nametake/golangci-lint-langserver/issues/8
local lspconfig = require "lspconfig"
local configs = require "lspconfig/configs"

if not lspconfig.golangcilsp then
  configs.golangcilsp = {
    default_config = {
      cmd = { "golangci-lint-langserver" },
      root_dir = lspconfig.util.root_pattern(".git", "go.mod"),
      init_options = {
        command = {
          "golangci-lint", "run", "--out-format", "json",
        },
      },
    },
  }
end
lspconfig.golangcilsp.setup {
  filetypes = { "go" }
}
