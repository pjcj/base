local install_path = Fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if Fn.empty(Fn.glob(install_path)) > 0 then
  Fn.system({
    "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path
  })
  Cmd "packadd packer.nvim"
end

require("packer").startup(function(use)
  -- Packer can manage itself
  use "wbthomason/packer.nvim"

  use "pjcj/neovim-colors-solarized-truecolor-only"

  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }

  use "neovim/nvim-lspconfig"
  use "kabouzeid/nvim-lspinstall"

  use "w0rp/ale"

  use { "fatih/vim-go", run = ":GoUpdateBinaries" }

  use {
    "nvim-telescope/telescope.nvim",
    requires = {{ "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" }}
  }

  use "hrsh7th/nvim-compe"
  use "andersevenrud/compe-tmux"

  use {
    "lewis6991/gitsigns.nvim",
    requires = {
      "nvim-lua/plenary.nvim"
    }
  }
  use "rhysd/git-messenger.vim"
  use "ruanyl/vim-gh-line"
  use "tpope/vim-fugitive"

  use "norcalli/nvim-colorizer.lua"
  use "terrortylor/nvim-comment"

  use "zsugabubus/crazy8.nvim"
  use { "lukas-reineke/indent-blankline.nvim", branch = "lua" }

  use {
    "hoob3rt/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true }
  }

  use "gioele/vim-autoswap"
  use "farmergreg/vim-lastplace"
  use "mhinz/vim-startify"
  use "lfv89/vim-interestingwords"
  use "junegunn/vim-easy-align"
  use "tpope/vim-surround"
end)

require "nvim-treesitter.configs".setup {
  ensure_installed = "maintained",
  highlight = {
    enable = true,
  },
  indent = {
    enable = false,
  },
}

G.ale_linters_explicit = 1
G.ale_disable_lsp      = 1
G.ale_sign_error       = ""
G.ale_sign_warning     = "⚠"
G.ale_linters = {
  yaml = { "circleci", "spectral", "swaglint", "yamllint" },
  sh   = { "bashate", "language_server", "shell", "shellcheck" },
}

G.go_auto_type_info              = 1
G.go_test_show_name              = 1
G.go_doc_max_height              = 40
G.go_doc_popup_window            = 1
G.go_diagnostics_enabled         = 1
G.go_diagnostics_level           = 2
G.go_template_autocreate         = 0
G.go_metalinter_command          = "golangci-lint"
G.go_metalinter_autosave         = 1
G.go_metalinter_autosave_enabled = { }
G.go_metalinter_enabled          = { }
G.go_fmt_options                 = { gofmt = "-s" }

require "telescope".setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
      "--glob",
      "!.git",
    },
    file_ignore_patterns = {
      ".git/.*"
    },
  },
}

require "compe".setup {
  enabled          = true,
  autocomplete     = true,
  debug            = false,
  min_length       = 1,
  preselect        = "disable",
  throttle_time    = 80,
  source_timeout   = 200,
  resolve_timeout  = 800,
  incomplete_delay = 400,
  max_abbr_width   = 100,
  max_kind_width   = 100,
  max_menu_width   = 100,
  documentation    = true,

  source = {
    path            = true,
    buffer          = true,
    calc            = true,
    spell           = { priority = 3 },
    emoji           = true,
    nvim_lsp        = true,
    nvim_lua        = true,
    vsnip           = false,
    ultisnips       = false,
    nvim_treesitter = false,
    tmux            = {
      priority  = 5,
      all_panes = true,
    },
  },
}

local t = function(str)
  return Api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = Fn.col(".") - 1
  if col == 0 or Fn.getline("."):sub(col, col):match("%s") then
    return true
  else
    return false
  end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if Fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif Fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return Fn["compe#complete"]()
  end
end

_G.s_tab_complete = function()
  if Fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif Fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end

Map("i", "<Tab>",   "v:lua.tab_complete()",   {expr = true})
Map("s", "<Tab>",   "v:lua.tab_complete()",   {expr = true})
Map("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
Map("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

require "gitsigns".setup {
  signs = {
    add          = { show_count = true, text = "+" },
    change       = { show_count = true, text = "~" },
    delete       = { show_count = true, text = "_" },
    topdelete    = { show_count = true, text = "‾" },
    changedelete = { show_count = true, text = "~" },
  },
  numhl   = false,
  linehl  = false,
  keymaps = {
    -- Default keymap options
    noremap = true,
    buffer  = true,

    ['n <F2>'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'"},
    ['n <F3>'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'"},

    ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ['v <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
    ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    ['v <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
    ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',

    ['n <F1>'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ['v <F1>'] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',

    -- Text objects
    ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
    ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>'
  },
  watch_index                 = { interval = 1000 },
  current_line_blame          = true,
  current_line_blame_delay    = 1000,
  current_line_blame_position = "eol",
  sign_priority               = 6,
  update_debounce             = 100,
  status_formatter            = nil, -- Use default
  use_decoration_api          = true,
  use_internal_diff           = true, -- If luajit is present
  count_chars = {
    [1]   = "₁",
    [2]   = "₂",
    [3]   = "₃",
    [4]   = "₄",
    [5]   = "₅",
    [6]   = "₆",
    [7]   = "₇",
    [8]   = "₈",
    [9]   = "₉",
    ["+"] = "₊",
  },
}

G.git_messenger_always_into_popup = 1
G.git_messenger_include_diff      = "current"
G.gh_use_canonical                = 0

Opt.termguicolors = true
require "colorizer".setup(
  { "*" },
  { names = true, RGB = true, RRGGBB = true, RRGGBBAA = true, css = true }
)

require "nvim_comment".setup({ line_mapping = "-" })

G.indent_blankline_char                           = " "
G.indent_blankline_space_char                     = " "
G.indent_blankline_show_trailing_blankline_indent = false

require "lualine".setup{
  options    = { theme  = "solarized_dark" },
  extensions = { "quickfix", "fugitive" },
  sections   = {
    lualine_c = {
      {
        "filename",
        file_status = true, -- (readonly, modified)
        path        = 1,    -- 0 = filename, 1 = relative, 2 = absolute
      },
      {
        "diff",
        colored = true,
        symbols = { added = "+", modified = "~", removed = "-" },
      },
      {
        "diagnostics",
        sources = { "nvim_lsp" },
      },
    },
  },
}

G.startify_change_to_vcs_root  = 1
G.startify_fortune_use_unicode = 1
G.startify_lists = {
    {
        type = "dir",
        header = {"   MRU " .. Fn.getcwd()}
    },
    {
        type = "sessions",
        header = {"   Sessions"}
    },
    {
        type = "files",
        header = {"   Files"}
    },
    {
        type = "bookmarks",
        header = {"   Bookmarks"}
    },
    {
        type = "commands",
        header = {"   Commands"}
    }
}

G.interestingWordsGUIColors = {
  '#72b5e4', '#f0c53f', '#ff8784', '#c5c7f1',
  '#c2d735', '#78d3cc', '#ea8336', '#e43542',
  '#ebab35', '#ebe735', '#aadd32', '#dcca6b',
  '#219286', '#2f569c', '#ffb577', '#5282a4',
  '#edfccf', '#67064c', '#f5bca7', '#95c474',
  '#dece83', '#de9783', '#f2e700', '#e9e9e9',
  '#69636d', '#626b98', '#f5f5a7', '#dcca6b',
  '#b72a83', '#6f2b9d', '#69636d', '#5f569c',
}
