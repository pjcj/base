--# selene: allow(mixed_table)

-- Text editing enhancement plugins
return {
  -- Syntax highlighting and code parsing using tree-sitter
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-refactor",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
      "windwp/nvim-ts-autotag",
    },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = "all",
        highlight = {
          enable = true,
          disable = {},
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<F53>",    -- option-f5
            scope_incremental = "<F55>", -- option-f7
            node_incremental = "<F53>",  -- option-f5
            node_decremental = "<F54>",  -- option-f6
          },
        },
        refactor = {
          highlight_definitions = { enable = true },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to the text object
            keymaps = {
              -- Custom text object for comments
              ["ia"] = "@comment.inner", -- Select inner part of a comment
              ["aa"] = "@comment.outer", -- Select outer part of a comment
            },
            include_surrounding_whitespace = false,
          },
        },
        autotag = {
          enable = true, -- closes tags automatically (eq html)
        },
      })
      require("treesitter-context").setup({
        enable = true,
        max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to show for a single context
        trim_scope = "outer",     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = "cursor",          -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20,     -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      })
    end,
  },

  -- Additional text objects for enhanced editing (numbers, URLs, etc.)
  {
    "chrisgrieser/nvim-various-textobjs",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      keymaps = { useDefaults = true },
    },
  },

  -- Context-aware comment strings for mixed-language files
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    opts = {
      enable_autocmd = true,
      ts_context_commentstring_module = true,
    },
  },

  -- Toggle comments with context-aware comment strings
  {
    "terrortylor/nvim-comment",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      require("nvim_comment").setup({
        line_mapping = "-",
        comment_empty = false,
        hook = function()
          require("ts_context_commentstring.internal").update_commentstring()
        end,
      })
      local l = require("local_defs")
      vim.api.nvim_set_keymap(
        "v",
        "-",
        ":<c-u>call CommentOperator(visualmode())<cr>",
        l.map.defmap
      )
    end,
  },

  -- Move lines and selections up/down/left/right
  {
    "matze/vim-move",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.g.move_map_keys = 0
      -- Keymaps are defined in mappings.lua using Ctrl+Shift+Arrow keys
    end,
  },

  -- Auto-close parentheses, brackets, and quotes
  {
    "cohama/lexima.vim",
    event = "InsertEnter",
    config = function()
      local lexima = vim.fn["lexima#add_rule"]
      local pattern = [[\%#\(\w\|\$\)]]

      lexima({ char = '"', at = pattern })
      lexima({ char = "'", at = pattern })
      lexima({ char = "`", at = pattern })
      lexima({ char = "(", at = pattern })
      lexima({ char = "[", at = pattern })
      lexima({ char = "{", at = pattern })
    end,
  },

  -- Add/change/delete surrounding characters (quotes, brackets, etc.)
  {
    "kylechui/nvim-surround",
    event = { "BufReadPre", "BufNewFile" },
    -- tag = "*",
    opts = {
      surrounds = {
        -- Perl word list qw with parentheses
        ["qw("] = {
          add = { "qw( ", " )" },
          find = "%f[%w]qw%b()",
          delete = "^(qw%( ?)().-( ?%))()$",
        },
        -- Perl word list qw with square brackets
        ["qw["] = {
          add = { "qw[ ", " ]" },
          find = "%f[%w]qw%b[]",
          delete = "^(qw%[ ?)().-( ?%])()$",
        },
        -- Perl word list qw with curly braces
        ["qw{"] = {
          add = { "qw{ ", " }" },
          find = "%f[%w]qw%b{}",
          delete = "^(qw{ ?)().-( ?%})()$",
        },
        -- Perl word list qw with angle brackets
        ["qw<"] = {
          add = { "qw< ", " >" },
          find = "%f[%w]qw%b<>",
          delete = "^(qw< ?)().-( ?%>)()$",
        },
        -- Perl qq with parentheses
        ["qq("] = {
          add = { "qq(", ")" },
          find = "%f[%w]qq%b()",
          delete = "^(qq%()().-(%))()$",
        },
        -- Perl qq with square brackets
        ["qq["] = {
          add = { "qq[", "]" },
          find = "%f[%w]qq%b[]",
          delete = "^(qq%[)().-(%])()$",
        },
        -- Perl qq with curly braces
        ["qq{"] = {
          add = { "qq{", "}" },
          find = "%f[%w]qq%b{}",
          delete = "^(qq{)().-(%})()$",
        },
        -- Perl qq with angle brackets
        ["qq<"] = {
          add = { "qq<", ">" },
          find = "%f[%w]qq%b<>",
          delete = "^(qq<)().-(%>)()$",
        },
        -- Perl q with parentheses
        ["q("] = {
          add = { "q(", ")" },
          find = "%f[%w]q%b()%f[%W]",
          delete = "^(q%()().-(%))()$",
        },
        -- Perl q with square brackets
        ["q["] = {
          add = { "q[", "]" },
          find = "%f[%w]q%b[]%f[%W]",
          delete = "^(q%[)().-(%])()$",
        },
        -- Perl q with curly braces
        ["q{"] = {
          add = { "q{", "}" },
          find = "%f[%w]q%b{}%f[%W]",
          delete = "^(q{)().-(%})()$",
        },
        -- Perl q with angle brackets
        ["q<"] = {
          add = { "q<", ">" },
          find = "%f[%w]q%b<>%f[%W]",
          delete = "^(q<)().-(%>)()$",
        },
      },
      aliases = {
        -- Q alias includes all Perl quote operators plus standard quotes
        -- Multi-character keys are more intuitive and memorable
        Q = { '"', "'", "`", "qw(", "qw[", "qw{", "qw<", "qq(", "qq[", "qq{", "qq<", "q(", "q[", "q{", "q<" },
      },
    },
  },

  -- Easy text alignment with regex patterns (gA then Ctrl-X)
  {
    "junegunn/vim-easy-align",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- Swap function arguments and list items (g< g> gs)
  {
    "machakann/vim-swap",
    keys = { "g<", "g>", "gs" },
  },

  -- Translate text using various translation services
  {
    "uga-rosa/translate.nvim",
    cmd = "Translate",
    -- Keymaps are defined in mappings.lua under "<leader> t" group
  },

  -- Enhanced word movement for camelCase and snake_case
  {
    "chrisgrieser/nvim-spider",
    -- Keymaps are defined in mappings.lua under which-key config
  },

  -- Find and open URLs in buffer (,fU)
  {
    "axieax/urlview.nvim",
    cmd = "UrlView",
    opts = {
      default_picker = "telescope",
      default_action = "clipboard",
    },
  },

  -- Split/join code blocks (functions, arrays, etc.) with treesitter
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = { use_default_keymaps = false, max_join_length = 80 },
    -- Keymaps are defined in mappings.lua under "<leader> j" group
  },

  -- Convert text to ASCII art blocks (:AsciiBlockify)
  {
    "superhawk610/ascii-blocks.nvim",
    cmd = "AsciiBlockify",
  },
}
