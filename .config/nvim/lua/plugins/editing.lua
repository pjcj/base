--# selene: allow(mixed_table)

-- Text editing enhancement plugins
return {
  -- Syntax highlighting and code parsing using tree-sitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
      "nvim-treesitter/nvim-treesitter-context",
    },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install("all")

      -- Enable treesitter highlighting for any filetype with a parser
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args) pcall(vim.treesitter.start, args.buf) end,
      })

      -- Disable treesitter indent for markdown
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function() vim.bo.indentexpr = "" end,
      })

      -- Incremental selection via treesitter nodes
      local sel_history = {}
      local function select_node(node, track)
        if not node then return end
        if track then table.insert(sel_history, node) end
        local sr, sc, er, ec = node:range()
        vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
        vim.fn.setpos("'>", { 0, er + 1, ec, 0 })
        vim.cmd("normal! gv")
      end

      vim.keymap.set("n", "<M-C-F5>", function() -- option-f5: init/expand
        sel_history = {}
        local node = vim.treesitter.get_node()
        select_node(node, true)
      end, { desc = "treesitter: init/expand selection" })

      vim.keymap.set("v", "<M-C-F5>", function() -- option-f5: expand
        local cur = sel_history[#sel_history]
        if cur then select_node(cur:parent() or cur, true) end
      end, { desc = "treesitter: expand selection" })

      vim.keymap.set("v", "<M-C-F6>", function() -- option-f6: shrink
        if #sel_history > 1 then
          table.remove(sel_history)
          select_node(sel_history[#sel_history], false)
        end
      end, { desc = "treesitter: shrink selection" })

      -- Textobjects
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          include_surrounding_whitespace = false,
        },
      })

      local ts_select = require("nvim-treesitter-textobjects.select")
      local ts_swap = require("nvim-treesitter-textobjects.swap")

      local select_maps = {
        ["ia"] = "@comment.inner",
        ["aa"] = "@comment.outer",
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
      }
      for keys, query in pairs(select_maps) do
        vim.keymap.set(
          { "x", "o" },
          keys,
          function() ts_select.select_textobject(query, "textobjects") end
        )
      end

      vim.keymap.set(
        "n",
        "gb",
        function() ts_swap.swap_next("@parameter.inner") end,
        { desc = "swap next parameter" }
      )
      vim.keymap.set(
        "n",
        "gB",
        function() ts_swap.swap_previous("@parameter.inner") end,
        { desc = "swap previous parameter" }
      )

      -- Treesitter context
      require("treesitter-context").setup({
        enable = true,
        max_lines = 3,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = "outer",
        mode = "topline",
        separator = nil,
        zindex = 20,
        on_attach = function(buf)
          local filetype =
            vim.api.nvim_get_option_value("filetype", { buf = buf })
          return filetype ~= "perl"
        end,
      })
    end,
  },

  -- Auto-close and auto-rename HTML/XML tags
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- enable_close = true, -- Auto close tags
      -- enable_rename = true, -- Auto rename pairs of tags
      -- enable_close_on_slash = false, -- Auto close on trailing </
    },
  },

  -- Additional text objects for enhanced editing (numbers, URLs, etc.)
  {
    "chrisgrieser/nvim-various-textobjs",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      keymaps = {
        useDefaults = true,
        disabledDefaults = { "!" },
      },
    },
  },

  -- Context-aware comment strings for mixed-language files
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    opts = {
      enable_autocmd = false,
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
        A = {
          add = { "qw( ", " )" },
          find = "%f[%w]qw%b()",
          delete = "^(qw%( ?)().-( ?%))()$",
        },
        -- Perl word list qw with square brackets
        N = {
          add = { "qw[ ", " ]" },
          find = "%f[%w]qw%b[]",
          delete = "^(qw%[ ?)().-( ?%])()$",
        },
        -- Perl word list qw with curly braces
        C = {
          add = { "qw{ ", " }" },
          find = "%f[%w]qw%b{}",
          delete = "^(qw{ ?)().-( ?%})()$",
        },
        -- Perl word list qw with angle brackets
        D = {
          add = { "qw< ", " >" },
          find = "%f[%w]qw%b<>",
          delete = "^(qw< ?)().-( ?%>)()$",
        },
        -- Perl word list qw with forward slashes
        E = {
          add = { "qw/", "/" },
          find = "%f[%w]qw/[^/]*/",
          delete = "^(qw/)().-(/())$",
        },
        -- Perl qq with parentheses
        F = {
          add = { "qq(", ")" },
          find = "%f[%w]qq%b()",
          delete = "^(qq%()().-(%))()$",
        },
        -- Perl qq with square brackets
        G = {
          add = { "qq[", "]" },
          find = "%f[%w]qq%b[]",
          delete = "^(qq%[)().-(%])()$",
        },
        -- Perl qq with curly braces
        H = {
          add = { "qq{", "}" },
          find = "%f[%w]qq%b{}",
          delete = "^(qq{)().-(%})()$",
        },
        -- Perl qq with angle brackets
        I = {
          add = { "qq<", ">" },
          find = "%f[%w]qq%b<>",
          delete = "^(qq<)().-(%>)()$",
        },
        -- Perl q with parentheses
        J = {
          add = { "q(", ")" },
          find = "%f[%w]q%b()%f[%W]",
          delete = "^(q%()().-(%))()$",
        },
        -- Perl q with square brackets
        K = {
          add = { "q[", "]" },
          find = "%f[%w]q%b[]%f[%W]",
          delete = "^(q%[)().-(%])()$",
        },
        -- Perl q with curly braces
        L = {
          add = { "q{", "}" },
          find = "%f[%w]q%b{}%f[%W]",
          delete = "^(q{)().-(%})()$",
        },
        -- Perl q with angle brackets
        M = {
          add = { "q<", ">" },
          find = "%f[%w]q%b<>%f[%W]",
          delete = "^(q<)().-(%>)()$",
        },
      },
      aliases = {
        -- Q alias includes all Perl quote operators plus standard quotes
        -- Multi-character keys are more intuitive and memorable
        Q = {
          '"',
          "'",
          "`",
          "A",
          "N",
          "C",
          "D",
          "E",
          "F",
          "G",
          "H",
          "I",
          "J",
          "K",
          "L",
          "M",
        },
      },
    },
  },

  -- Show marks in the gutter
  {
    "chentoast/marks.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    config = function(_, opts)
      require("marks").setup(opts)

      -- Store the original marks 'm' mapping
      local marks_m = vim.fn.maparg("m", "n", false, true)

      -- Replace with custom mapping that shows which-key first
      vim.keymap.set("n", "m", function()
        require("which-key").show({ keys = "m", mode = "n" })
        local char = vim.fn.getcharstr()
        -- Call original marks.nvim callback with the character
        if marks_m.callback then marks_m.callback(char) end
      end, { desc = "marks (mx=set, m[0-9]=bookmark)" })
    end,
  },

  -- Easy text alignment with regex patterns (gA then Ctrl-X)
  {
    "junegunn/vim-easy-align",
    event = { "BufReadPre", "BufNewFile" },
    init = function() vim.g.easy_align_ignore_groups = {} end,
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

  -- Hex editor and binary inspector
  {
    "Punity122333/hexinspector.nvim",
    cmd = { "HexEdit", "HexInspect" },
    keys = {
      {
        "<leader> hx",
        function() require("hexinspector").open() end,
        desc = "hex edit",
      },
      {
        "<leader> hX",
        function()
          vim.ui.input(
            { prompt = "File path: ", default = vim.fn.expand("%:p") },
            function(input)
              if input and input ~= "" then
                require("hexinspector").open(input)
              end
            end
          )
        end,
        desc = "hex edit (pick file)",
      },
    },
    config = function()
      local c = require("local_defs").colour
      require("hexinspector").setup({
        colors = {
          bg = c.base03,
          info_bg = c.base06,
          border = c.cyan,
          addr = c.base01,
          hex = c.base0,
          ascii = c.green,
          null = c.base05,
          cursor_bg = c.base05,
          cursor_line_bg = c.base06,
          float = c.orange,
          int = c.violet,
          uint = c.cyan,
          title = c.blue,
          search = c.magenta,
          modified = c.red,
          selection_bg = c.ddblue,
        },
      })
    end,
  },
}
