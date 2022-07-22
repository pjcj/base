local install_path = vim.fn.stdpath "data"
    .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system {
    "git",
    "clone",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  vim.cmd "packadd packer.nvim"
end

vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]]

local packer = require("packer")
packer.init {
  max_jobs = 15,
  git = {
    depth = 9999999,
  },
  profile = {
    enable = true,
    threshold = 1, -- integer in milliseconds
  },
}

packer.startup(function(use)
  -- Packer can manage itself
  use "wbthomason/packer.nvim"

  use {
    "feline-nvim/feline.nvim",
    config = function()
      require "statusline"
    end,
  }
  use "kyazdani42/nvim-web-devicons"
  use "pjcj/neovim-colors-solarized-truecolor-only"

  use {
    "nvim-treesitter/nvim-treesitter",
    requires = {
      "nvim-treesitter/nvim-treesitter-refactor",
      "nvim-treesitter/playground",
      "JoosepAlviste/nvim-ts-context-commentstring",
      "windwp/nvim-ts-autotag",
    },
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = "all",
        ignore_install = {
          "swift", -- requires glibc 2.28
          "perl", -- sometimes crashes
          "phpdoc", -- fails on MacOS
        },
        highlight = {
          enable = true,
          -- disable = { "perl" },
        },
        indent = { enable = false },
        refactor = {
          highlight_definitions = { enable = true },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<tab>",
            scope_incremental = "<cr>",
            node_incremental = "<tab>",
            node_decremental = "<s-tab>",
          },
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        autotag = {
          enable = true,
        },
      }
    end,
  }

  use {
    "terrortylor/nvim-comment",
    config = function()
      require("nvim_comment").setup {
        line_mapping = "-",
        comment_empty = false,
        hook = function()
          require("ts_context_commentstring.internal").update_commentstring()
        end,
      }
      local l = require "local_defs"
      vim.api.nvim_set_keymap(
        "v",
        "-",
        ":<c-u>call CommentOperator(visualmode())<cr>",
        l.map.defmap
      )
    end,
  }

  use {
    "lewis6991/spellsitter.nvim",
    config = function()
      require("spellsitter").setup {
        hl = "SpellBad",
        captures = { "comment" }, -- set to {} to spellcheck everything
      }
    end,
  }

  use "neovim/nvim-lspconfig"
  use "williamboman/nvim-lsp-installer"
  use "ray-x/lsp_signature.nvim"
  -- use "folke/lsp-colors.nvim"
  use {
    "kosayoda/nvim-lightbulb",
    requires = "antoinemadec/FixCursorHold.nvim",
    config = function()
      vim.cmd [[
        augroup lightbulb
          autocmd!
          autocmd CursorHold,CursorHoldI * lua require "nvim-lightbulb".update_lightbulb()
        augroup end
      ]]
      require("nvim-lightbulb").setup {
        sign = {
          enabled = false,
          priority = 1,
        },
        virtual_text = {
          enabled = true,
        },
      }
    end,
  }
  use {
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  }
  use "jose-elias-alvarez/nvim-lsp-ts-utils"
  -- use {
  --   -- :lua vim.lsp.buf.incoming_calls()
  --   -- :lua vim.lsp.buf.outgoing_calls()
  --   "ldelossa/calltree.nvim",
  --   config = function()
  --     require "calltree".setup({})
  --   end,
  -- }
  require("lsp").setup_servers()

  use {
    "dense-analysis/ale",
    config = function()
      vim.g.ale_linters_explicit = 0
      vim.g.ale_disable_lsp = 1
      vim.g.ale_virtualtext_cursor = 1
      vim.g.ale_sign_error = "e"
      vim.g.ale_sign_warning = "w"
      vim.g.ale_sign_info = "i"
      vim.g.ale_echo_msg_format = "[%severity%] [%linter%] %s"
      vim.g.ale_linters = {
        -- go = { "gofmt", "golint", "gopls", "govet", "golangci-lint" },
        yaml = { "circleci", "spectral", "swaglint" },
      }
    end,
  }

  use {
    "ludovicchabant/vim-gutentags",
    config = function()
      vim.g.gutentags_ctags_exclude = vim.g.gutentags_ctags_exclude or {}
      local ex = vim.g.gutentags_ctags_exclude
      local exclude = {
        "tmp",
        "blib",
        "node_modules",
        "dist",
      }
      for _, v in pairs(exclude) do
        table.insert(ex, v)
      end
      vim.g.gutentags_ctags_exclude = ex
      -- print(vim.inspect(vim.g.gutentags_ctags_exclude))

      -- can be extended with '*/sub/path' if required
      vim.g.gutentags_generate_on_new = 1
      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_generate_on_empty_buffer = 0
    end,
  }

  use {
    "SmiteshP/nvim-gps",
    requires = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-gps").setup {
        -- icons = {
        --   ["class-name"] = "",
        --   ["function-name"] = "",
        --   ["method-name"] = "",
        --   ["container-name"] = 'ﮅ',
        --   ["tag-name"] = '炙',
        -- },
        -- Any language not disabled here is enabled by default
        -- languages = {
        --   -- ["bash"] = false,
        --   -- ["go"]   = false,
        -- },
        -- separator = " > ",
        depth = 5,
      }
    end,
  }

  use {
    "ray-x/go.nvim",
    requires = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "ray-x/guihua.lua", -- float term, codeaction and codelens gui support
    },
    config = function()
      require("go").setup {
        goimport = "goimports",
        lsp_cfg = false,
        lsp_diag_hdlr = false,
        lsp_fmt_async = true,
        lsp_gofumpt = true,
        max_line_len = 80, -- max line length in goline format
        null_ls_document_formatting_disable = true,
      }

      vim.cmd [[
        augroup gofmt
          autocmd!
          autocmd BufWritePre *.go :silent! lua require("go.format").goimport()
        augroup end
      ]]
    end,
  }

  use {
    "vim-perl/vim-perl",
    run = "make clean carp dancer heredoc-sql highlight-all-pragmas "
        .. "js-css-in-mason method-signatures moose test-more try-tiny",
    config = function()
      vim.g.perl_highlight_data = 1
    end,
  }

  use {
    "ThePrimeagen/refactoring.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local refactoring = require "refactoring"

      refactoring.setup {
        installation_path = vim.fn.stdpath "data" .. "/dapinstall/",
      }
    end,
  }

  use "mfussenegger/nvim-dap"
  -- use {
  --   "Pocco81/DAPInstall.nvim",
  --   config = function()
  --     local dap_install = require "dap-install"

  --     dap_install.setup {
  --       installation_path = vim.fn.stdpath "data" .. "/dapinstall/",
  --     }

  --     local dbg_list =
  --       require("dap-install.api.debuggers").get_installed_debuggers()

  --     for _, debugger in ipairs(dbg_list) do
  --       dap_install.config(debugger)
  --     end
  --   end,
  -- }

  use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }
  use {
    "nvim-telescope/telescope.nvim",
    requires = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "protex/better-digraphs.nvim",
      "nvim-telescope/telescope-dap.nvim",
    },
    config = function()
      local telescope = require "telescope"
      local actions = require "telescope.actions"
      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ["<c-s>"] = actions.select_vertical,
              ["<c-k>"] = actions.which_key,
            },
            n = {
              ["<c-s>"] = actions.select_vertical,
              ["<c-k>"] = actions.which_key,
            },
          },
          extensions = {
            fzf = {
              -- default options
              fuzzy = true,
              case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            },
          },
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
            ".git/.*",
          },
          dynamic_preview_title = true,
        },
      }

      telescope.load_extension "fzf"
      telescope.load_extension "refactoring"

      vim.cmd [[
        augroup telescope
          autocmd!
          autocmd User TelescopePreviewerLoaded setlocal number
          autocmd User TelescopePreviewerLoaded setlocal tabstop=2
        augroup end
      ]]
    end,
  }
  use "stevearc/dressing.nvim"

  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/vim-vsnip",
      "hrsh7th/vim-vsnip-integ",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "quangnguyen30192/cmp-nvim-tags",
      "andersevenrud/cmp-tmux",
      "onsails/lspkind-nvim",
      "rafamadriz/friendly-snippets",
      "uga-rosa/cmp-dictionary",
    },
    config = function()
      require("cmp_nvim_lsp").setup()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
      local cmp = require "cmp"
      local lspkind = require "lspkind"
      local compare = cmp.config.compare

      -- stylua: ignore start
      lspkind.init({
        symbol_map = {
          Text          = "",
          Method        = "",
          Function      = "",
          Constructor   = "",
          Field         = "",
          Variable      = "",
          Class         = "ﴯ",
          Interface     = "",
          Module        = "",
          Property      = "ﰠ",
          Unit          = "",
          Value         = "",
          Enum          = "",
          Keyword       = "",
          Snippet       = "",
          Color         = "",
          File          = "",
          Reference     = "",
          Folder        = "",
          EnumMember    = "",
          Constant      = "",
          Struct        = "פּ",
          Event         = "",
          Operator      = "",
          TypeParameter = ""
        }
      })
      -- stylua: ignore end

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
            and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
            :sub(col, col)
            :match "%s"
            == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes(key, true, true, true),
          mode,
          true
        )
      end

      cmp.setup {
        formatting = {
          format = lspkind.cmp_format {
            mode = "symbol_text",
            maxwidth = 80,
            menu = {
              buffer = "buf",
              nvim_lsp = "lsp",
              nvim_lua = "lua",
              path = "path",
              tmux = "tmux",
              tags = "tags",
              vsnip = "snip",
              calc = "calc",
              spell = "spell",
              emoji = "emoji",
              dictionary = "dict",
            },
            before = function(entry, vim_item)
              vim_item.dup = ({
                nvim_lsp = 0,
                buffer = 0,
                tags = 0,
                path = 0,
                tmux = 0,
                dictionary = 0,
              })[entry.source.name] or 0
              return vim_item
            end,
          },
        },
        experimental = {
          native_menu = false,
          ghost_text = true,
          horizontal_search = true,
        },
        min_length = 1,
        mapping = {
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-e>"] = cmp.mapping {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          },
          ["<C-x>"] = cmp.mapping.confirm { select = true },
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              feedkey("<Plug>(vsnip-jump-prev)", "")
            end
          end, { "i", "s" }),
        },
        sources = {
          { name = "nvim_lua" },
          { name = "nvim_lsp_signature_help" },
          { name = "nvim_lsp" },
          {
            name = "buffer",
            option = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end,
              -- keywords or just words
              keyword_pattern = [[\%(\k\+\|\w\+\)]],
            },
          },
          { name = "tags" },
          { name = "path" },
          {
            name = "tmux",
            option = { all_panes = true, label = "[tmux]" },
          },
          { name = "calc" },
          { name = "emoji" },
          {
            name = "dictionary",
            keyword_length = 2,
          },
        },
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          end,
        },
        sorting = {
          priority_weight = 1.0,
          comparators = {
            compare.locality,
            compare.recently_used,
            compare.scopes,
            compare.score,
            -- score = score +
            --  ((#sources - (source_index - 1)) * sorting.priority_weight)
            compare.offset,
            compare.order,
            -- compare.score_offset,
            -- compare.sort_text,
            -- compare.exact,
            -- compare.kind,
            -- compare.length,
          },
        },
      }

      require("cmp_dictionary").setup {
        dic = {
          ["*"] = { "/usr/share/dict/words" },
          -- ["lua"] = "path/to/lua.dic",
          -- ["javascript,typescript"] = { "path/to/js.dic", "path/to/js2.dic" },
          -- filename = {
          --   ["xmake.lua"] = { "path/to/xmake.dic", "path/to/lua.dic" },
          -- },
          -- filepath = {
          --   ["%.tmux.*%.conf"] = "path/to/tmux.dic"
          -- },
        },
        -- The following are default values, so you don't need to write them if
        -- you don't want to change them
        -- exact = 2,
        -- first_case_insensitive = false,
        -- async = false,
        -- capacity = 5,
        -- debug = false,
      }

      -- Use buffer source for `/`.
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':'.
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  }

  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
        window = {
          border = "single",
        },
        layout = {
          width = {
            max = 80,
          },
          height = {
            max = 40,
          },
        },
        plugins = {
          spelling = {
            enabled = true,
            suggestions = 20,
          },
        },
      }
    end,
  }

  use {
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup {
        signs = {
          add = { show_count = true, text = "+" },
          change = { show_count = true, text = "~" },
          delete = { show_count = true, text = "_" },
          topdelete = { show_count = true, text = "‾" },
          changedelete = { show_count = true, text = "~" },
        },
        numhl = false,
        linehl = false,
        watch_gitdir = { interval = 1000 },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        diff_opts = { internal = true }, -- If luajit is present
        word_diff = true,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
        },
        count_chars = {
          [1] = "₁",
          [2] = "₂",
          [3] = "₃",
          [4] = "₄",
          [5] = "₅",
          [6] = "₆",
          [7] = "₇",
          [8] = "₈",
          [9] = "₉",
          ["+"] = "₊",
        },
        on_attach = function(bufnr)
          local function map(mode, lhs, rhs, opts)
            opts = vim.tbl_extend(
              "force",
              { noremap = true, silent = true },
              opts or {}
            )
            vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
          end

          -- Text object
          map("o", "ih", ":<C-U>Gitsigns select_hunk<CR>")
          map("x", "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      }
    end,
  }

  use {
    "rhysd/git-messenger.vim",
    config = function()
      vim.g.git_messenger_always_into_popup = 1
      vim.g.git_messenger_include_diff = "current"
    end,
  }

  use "rhysd/conflict-marker.vim"

  use {
    "ruanyl/vim-gh-line",
    config = function()
      vim.g.gh_use_canonical = 0
    end,
  }

  use "tpope/vim-fugitive"

  use {
    "norcalli/nvim-colorizer.lua",
    config = function()
      vim.opt.termguicolors = true
      require("colorizer").setup()
    end,
  }

  use {
    "AckslD/nvim-neoclip.lua",
    requires = { "tami5/sqlite.lua", module = "sqlite" },
    config = function()
      require("neoclip").setup {
        enable_persistent_history = true,
        db_path = vim.fn.stdpath "data" .. "/databases/neoclip.sqlite3",
        default_register = '"',
      }
    end,
  }

  use "zsugabubus/crazy8.nvim"
  use {
    "gpanders/editorconfig.nvim",
    after = "crazy8.nvim",
  }
  use {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      -- stylua: ignore
      require "indent_blankline".setup {
        char                                       = " ",
        space_char                                 = " ",
        context_char                               = "┃",
        show_trailing_blankline_indent             = false,
        show_first_indent_level                    = true,
        max_indent_increase                        = 1,
        viewport_buffer                            = 100,
        show_current_context                       = true,
        show_current_context_start                 = true,
        show_current_context_start_on_current_line = false,
        use_treesitter_scope                       = true,
        buftype_exclude                            = { "terminal" },
        filetype_exclude                           = {
          "diff", "help", "markdown", "packer", "qf", "lspinfo", "checkhealth",
          -- "perl",
          "man",
          "",
        },
        -- TODO - remove
        context_patterns = {
          -- defaults
          "class", "^func", "method", "^if", "while", "for", "with",
          "try", "except", "arguments", "argument_list", "object",
          "dictionary", "element", "table", "tuple",
          -- general
          "^arguments",
          -- go
          "^func_literal", "^import_declaration", "^const_declaration",
          "^var_declaration", "^short_var_declaration", "^type_declaration",
          "^expression_switch_statement", "^expression_case",
          -- bash
          "^case_statement", "^case_item",
          -- perl  # the TS implementation here isn't all that good
          -- "^block", "^package_statement", "^use_constant_statement",
          -- lua
          "^local_function",
        },
      }
    end,
  }

  use {
    "matze/vim-move",
    config = function()
      vim.g.move_map_keys = 0
    end,
  }

  use "gioele/vim-autoswap"
  use "farmergreg/vim-lastplace"

  use {
    "mhinz/vim-startify",
    config = function()
      vim.g.startify_change_to_vcs_root = 1
      vim.g.startify_fortune_use_unicode = 1
      vim.g.startify_lists = {
        { type = "dir", header = { "   MRU " .. vim.fn.getcwd() } },
        { type = "sessions", header = { "   Sessions" } },
        { type = "files", header = { "   Files" } },
        { type = "bookmarks", header = { "   Bookmarks" } },
        { type = "commands", header = { "   Commands" } },
      }
    end,
  }

  use {
    "lfv89/vim-interestingwords",
    config = function()
      -- stylua: ignore
      vim.g.interestingWordsGUIColors = {
        '#72b5e4', '#f0c53f', '#ff8784', '#c5c7f1',
        '#c2d735', '#78d3cc', '#ea8336', '#e43542',
        '#ebab35', '#ebe735', '#aadd32', '#dcca6b',
        '#219286', '#2f569c', '#ffb577', '#5282a4',
        '#edfccf', '#67064c', '#f5bca7', '#95c474',
        '#dece83', '#de9783', '#f2e700', '#e9e9e9',
        '#69636d', '#626b98', '#f5f5a7', '#dcca6b',
        '#b72a83', '#6f2b9d', '#69636d', '#5f569c',
      }
    end,
  }

  use {
    "cohama/lexima.vim",
    config = function()
      vim.cmd [[
        call lexima#add_rule({"char": '"', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": "'", "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '`', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '(', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '[', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '{', "at": '\%#\(\w\|\$\)'})
      ]]
    end,
  }

  use "junegunn/vim-easy-align"
  use "tpope/vim-surround"
  use "tpope/vim-repeat"
  use "windwp/nvim-ts-autotag"
  use "AndrewRadev/splitjoin.vim" -- gS, gJ
  use "Konfekt/vim-unicode-homoglyphs" -- gy
  use "ntpeters/vim-better-whitespace"
  use "ojroques/vim-oscyank"
  use "uga-rosa/translate.nvim"
  use "kana/vim-textobj-user"
  use {
    "Julian/vim-textobj-variable-segment",
    after = "vim-textobj-user",
  }

  use "axieax/urlview.nvim"

  use {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require "notify"
    end,
  }

  use {
    "dstein64/nvim-scrollview",
    config = function()
      vim.g.scrollview_winblend = 75
      vim.g.scrollview_column = 1
    end,
  }

  use {
    "sidebar-nvim/sidebar.nvim",
    -- branch = "dev",
    config = function()
      local sidebar = require "sidebar-nvim"
      local opts = {
        open = false,
        sections = { "git", "diagnostics", "buffers", "symbols" },
        disable_closing_prompt = true,
      }
      sidebar.setup(opts)
    end,
  }

  use {
    "simrat39/symbols-outline.nvim",
    requires = {
      "folke/which-key.nvim",
    },
    config = function()
      vim.g.symbols_outline = {
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = "right",
        relative_width = true,
        width = 80,
        auto_close = true,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = "Pmenu",
        keymaps = { -- These keymaps can be a string or a table for multiple keys
          close = { "<Esc>", "q" },
          goto_location = "<Cr>",
          focus_location = "o",
          hover_symbol = "<C-space>",
          toggle_preview = "K",
          rename_symbol = "r",
          code_actions = "a",
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
      }
    end,
  }

  use {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {
        highlight = {
          before = "", -- "fg" or "bg" or empty
          keyword = "fg", -- "fg", "bg", "wide" or empty
          after = "fg", -- "fg" or "bg" or empty
          pattern = { -- pattern or table of patterns - vim regex
            [[ (KEYWORDS)>(:| +\d| -)]],
          },
          comments_only = true, -- uses treesitter to match keywords in comments
          max_line_len = 400, -- ignore lines longer than this
          exclude = {}, -- list of file types to exclude highlighting
        },
        merge_keywords = true,
        keywords = {
          TODO = {
            icon = "",
            alt = { "DEBUG" },
          },
          FIX = {
            alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "ERROR", "FATAL" },
          },
        },
        search = {
          pattern = [[\b(KEYWORDS)(:| +\d| -)]], -- ripgrep regex
        },
      }
    end,
  }
  -- ERROR: red
  -- WARN 123
  -- INFO  456
  -- ISSUE    78
  -- DEBUG - rrr
  -- BUG no
  -- FIXIT .red
  --ERROR: 5
  --ERROR 6
  --- TODO - hmmm

  use "elihunter173/dirbuf.nvim"
  use {
    "kyazdani42/nvim-tree.lua",
    requires = {
      "kyazdani42/nvim-web-devicons", -- optional, for file icon
    },
    config = function()
      require("nvim-tree").setup {
        hijack_directories = { enable = false },
      }
    end,
  }

  use {
    "edluffy/specs.nvim",
    config = function()
      local specs = require "specs"
      specs.setup {
        show_jumps = true,
        min_jump = 5,
        popup = {
          delay_ms = 0, -- delay before popup displays
          inc_ms = 5, -- time increments used for fade/resize effects
          blend = 10, -- starting blend, between 0-100, see :h winblend
          width = 40,
          winhl = "ScrollView",
          fader = specs.linear_fader,
          resizer = specs.shrink_resizer,
        },
        ignore_filetypes = {},
        ignore_buftypes = { nofile = true },
      }
      local l = require "local_defs"
      vim.api.nvim_set_keymap(
        "n",
        "ä",
        [[<cmd>lua require "specs".show_specs()<cr>]],
        l.map.defmap
      )
    end,
  }

  use {
    "iamcco/markdown-preview.nvim",
    run = "cd app && yarn install",
    ft = "markdown",
  }
end)
