-- Colorscheme and visual highlighting plugins

return {
  -- Solarized-inspired colorscheme with custom color overrides
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    config = function()
      local c = require("local_defs").colour
      require("catppuccin").setup({
        color_overrides = {
          all = {
            -- stylua: ignore start
            rosewater = c.c_rosewater,
            flamingo  = c.c_flamingo,
            pink      = c.c_pink,
            mauve     = c.c_mauve,
            red       = c.c_red,
            maroon    = c.c_maroon,
            peach     = c.c_peach,
            yellow    = c.c_yellow,
            green     = c.c_green,
            teal      = c.c_teal,
            sky       = c.c_sky,
            sapphire  = c.c_sapphire,
            blue      = c.c_blue,
            lavender  = c.c_lavender,
            text      = c.c_text,
            subtext1  = c.c_subtext1,
            subtext0  = c.c_subtext0,
            overlay2  = c.c_overlay2,
            overlay1  = c.c_overlay1,
            overlay0  = c.c_overlay0,
            surface2  = c.c_surface2,
            surface1  = c.c_surface1,
            surface0  = c.c_surface0,
            base      = c.c_base,
            mantle    = c.c_mantle,
            crust     = c.c_crust,
            -- stylua: ignore end
          },
        },
        integrations = {
          blink_cmp = {
            style = "bordered",
          },
          gitsigns = true,
          indent_blankline = true,
          mason = true,
          notify = true,
          nvimtree = true,
          overseer = true,
          symbols_outline = true,
          treesitter = true,
          which_key = true,
          telescope = {
            enabled = true,
          },
        },
        custom_highlights = function(col)
          return {
            BlinkCmpKindCodeium = { fg = col.lavender },
            BlinkCmpKindCopilot = { fg = col.peach },
            BlinkCmpKindSupermaven = { fg = col.teal },
            BlinkCmpKindTmux = { fg = c.rgreen },
            CmpItemKindCodeium = { fg = col.lavender },
            CmpItemKindCopilot = { fg = col.peach },
            CmpItemKindSupermaven = { fg = col.teal },
            CurSearch = { bg = col.surface2, fg = col.yellow },
            Cursor = { bg = c.llyellow },
            CursorColumn = { bg = col.surface1 },
            CursorLine = { bg = col.surface1 },
            DiagnosticFloatingHint = { fg = c.blue },
            DiagnosticHint = { fg = c.blue },
            DiagnosticSignHint = { fg = c.blue },
            DiagnosticVirtualTextHint = { fg = c.blue },
            DiffAdded = { fg = c.rgreen },
            DiffRemoved = { fg = c.red },
            ExtraWhitespace = { bg = c.mred },
            GitSignsCurrentLineBlame = { bg = col.base, fg = c.dblue },
            GitSignsDeleteVirtLn = { bg = col.mantle, fg = c.mred },
            IblIndent1 = { fg = c.dblue },
            IblIndent2 = { fg = c.dviolet },
            IblScope = { fg = c.yellow },
            IncSearch = { bg = col.yellow, fg = col.surface1 },
            LineNr = { fg = c.dblue },
            LspDiagnosticsDefaultHint = { fg = c.blue },
            LspDiagnosticsHint = { fg = c.blue },
            LspDiagnosticsVirtualTextHint = { fg = c.blue },
            MarkviewPalette1 = { fg = c.lred, bg = col.base },
            MarkviewPalette1Bg = { fg = col.base },
            MarkviewPalette1Fg = { fg = c.lred },
            MarkviewPalette1Sign = { fg = c.lred },
            MarkviewPalette2 = { fg = c.lyellow, bg = col.base },
            MarkviewPalette2Bg = { fg = col.base },
            MarkviewPalette2Fg = { fg = c.lyellow },
            MarkviewPalette2Sign = { fg = c.lyellow },
            MarkviewPalette3 = { fg = c.peach, bg = col.base },
            MarkviewPalette3Bg = { fg = col.base },
            MarkviewPalette3Fg = { fg = c.peach },
            MarkviewPalette3Sign = { fg = c.peach },
            MarkviewPalette4 = { fg = c.lgreen, bg = col.base },
            MarkviewPalette4Bg = { fg = col.base },
            MarkviewPalette4Fg = { fg = c.lgreen },
            MarkviewPalette4Sign = { fg = c.lgreen },
            MarkviewPalette5 = { fg = c.llblue, bg = col.base },
            MarkviewPalette5Bg = { fg = col.base },
            MarkviewPalette5Fg = { fg = c.llblue },
            MarkviewPalette5Sign = { fg = c.llblue },
            MarkviewPalette6 = { fg = c.lviolet, bg = col.base },
            MarkviewPalette6Bg = { fg = col.base },
            MarkviewPalette6Fg = { fg = c.lviolet },
            MarkviewPalette6Sign = { fg = c.lviolet },
            MarkviewPalette7 = { fg = c.mviolet, bg = col.base },
            MarkviewPalette7Bg = { fg = col.base },
            MarkviewPalette7Fg = { fg = c.mviolet },
            MarkviewPalette7Sign = { fg = c.mviolet },
            MatchParen = { bg = col.blue, fg = col.base },
            Pmenu = { bg = c.dddred },
            PmenuSel = { bg = c.dred },
            Search = { bg = c.lyellow, fg = col.surface1 },
            -- SpellBad = { bg = col.base, fg = c.dorange },
            SpellCap = { bg = c.blue, fg = col.base },
            SpellLocal = { bg = c.green, fg = col.base },
            SpellRare = { bg = c.yellow, fg = col.base },
            TabLine = { bg = col.base, fg = col.overlay1 },
            VertSplit = { bg = col.base, fg = c.yellow },
            Visual = { bg = c.dred, fg = c.base1 },
            Whitespace = { fg = c.red },
            ["@text.danger"] = { bg = col.base, fg = c.red, bold = true },
            ["@text.note"] = { bg = col.base, fg = col.blue, bold = true },
            ["@text.todo"] = { bg = col.base, fg = col.yellow, bold = true },
            ["@text.warning"] = { bg = col.base, fg = c.yellow, bold = true },
            TreesitterContext = { bg = col.surface1 },
          }
        end,
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Highlight color codes with their actual colors
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.opt.termguicolors = true
      require("nvim-highlight-colors").setup({
        render = "background", -- background, foreground, virtual
        virtual_symbol = "■",
        enable_short_hex = false,
        enable_named_colors = true,
        enable_tailwind = true,
      })
    end,
  },

  -- Highlight characters that look similar but are different (homoglyphs)
  { "zsugabubus/crazy8.nvim" },

  -- Show indent guides and scope highlighting
  {
    "lukas-reineke/indent-blankline.nvim",
    version = "*",
    cmd = "IBLEnable",
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "╏",
        highlight = { "IblIndent1", "IblIndent2" },
      },
      exclude = {
        filetypes = { "startify" },
      },
      scope = {
        show_exact_scope = true,
        include = {
          node_type = {
            go = { "import_declaration" },
            lua = { "return_statement", "table_constructor" },
          },
        },
      },
      whitespace = {
        remove_blankline_trail = true,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd({ "VimEnter" }, {
        callback = function()
          vim.cmd(":IBLEnable")
        end,
      })
    end,
  },

  -- Highlight multiple words in different colors
  {
    "lfv89/vim-interestingwords",
    event = { "BufReadPre", "BufNewFile" },
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
  },

  -- Highlight matching text under cursor in surrounding area
  {
    "rareitems/hl_match_area.nvim",
    opts = {
      n_lines_to_search = 500,
      highlight_in_insert_mode = true,
      delay = 500,
    },
  },

  -- Highlight text additions and deletions
  {
    "aileot/emission.nvim",
    event = "UIEnter",
    opts = {
      highlight = {
        duration = 500,
      },
      added = {
        hl_map = {
          link = "Cursor",
        },
      },
    },
  },

  -- Enhanced search with lens showing match count and position
  {
    "kevinhwang91/nvim-hlslens",
    opts = {},
  },

  -- Detect unicode homoglyphs (gy)
  { "Konfekt/vim-unicode-homoglyphs" },

  -- Automatic color highlighting for LSP diagnostics
  { "folke/lsp-colors.nvim" },
}