-- Completion engine and sources

-- Helper functions for blink.cmp configuration
local kind_highlight = function(ctx)
  if ctx.source_name == "tmux" then
    return "BlinkCmpKindTmux"
  elseif ctx.source_name == "codeium" then
    return "BlinkCmpKindCodeium"
  elseif ctx.source_name == "copilot" then
    return "BlinkCmpKindCopilot"
  elseif ctx.source_name == "supermaven" then
    return "BlinkCmpKindSupermaven"
  end
  return ctx.kind_hl or ("BlinkCmpKind" .. (ctx.kind or "Unknown"))
end

local kind_text = function(ctx)
  if ctx.source_name == "tmux" then
    return "Tmux"
  elseif ctx.source_name == "codeium" then
    return "Codeium"
  elseif ctx.source_name == "copilot" then
    return "Copilot"
  elseif ctx.source_name == "supermaven" then
    return "Supermaven"
  end
  return ctx.kind
end

return {
  -- Colorful completion menu for better visual distinction
  {
    "xzbdmw/colorful-menu.nvim",
    opts = {},
  },

  -- Compatibility layer for nvim-cmp sources with blink.cmp
  {
    "saghen/blink.compat",
    version = "2.*", -- use v2.* for blink.cmp v1.*
    enabled = true,
    opts = {},
  },

  -- Fast completion engine with AI provider support and fuzzy matching
  {
    "saghen/blink.cmp",
    version = "1.*",
    enabled = true,
    event = "InsertEnter",
    dependencies = {
      {
        "milanglacier/minuet-ai.nvim", -- Multi-provider AI
        enabled = _G.using_ai(),
      },
      {
        "fang2hou/blink-copilot",
        enabled = _G.using_ai(),
      },
      {
        "huijiro/blink-cmp-supermaven",
        enabled = _G.using_ai(),
      },
      {
        "Exafunction/codeium.nvim",
        enabled = _G.using_ai(),
      },
      "moyiz/blink-emoji.nvim",
      {
        "Kaiser-Yang/blink-cmp-dictionary",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
      "mgalliou/blink-cmp-tmux",
      "hrsh7th/vim-vsnip",
      "hrsh7th/vim-vsnip-integ",
      "https://codeberg.org/FelipeLema/blink-cmp-vsnip.git",
    },
    config = function()
      local sources = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        -- "omni",
        "emoji",
        "dictionary",
        -- "tmux",  # slows down insert too much
        "vsnip",
      }

      if _G.using_ai() then
        table.insert(sources, "copilot")
        table.insert(sources, "supermaven")
        table.insert(sources, "minuet")
        table.insert(sources, "codeium")
      end

      local providers = {
        lsp = {
          async = true,
          timeout_ms = 2000,
          max_items = 10,
          fallbacks = {},
        },
        path = {
          opts = {
            get_cwd = function(_) return vim.fn.getcwd() end,
          },
        },
        buffer = {
          max_items = 5,
          opts = {
            -- get all buffers, even ones like neo-tree
            get_bufnrs = vim.api.nvim_list_bufs,
            -- or (recommended) filter to only "normal" buffers
            -- get_bufnrs = function()
            --   return vim.tbl_filter(function(bufnr)
            --     return vim.bo[bufnr].buftype == ''
            --   end, vim.api.nvim_list_bufs())
            -- end
          },
        },
        snippets = {
          -- Built-in snippets provider
        },
        emoji = {
          module = "blink-emoji",
          name = "Emoji",
          opts = {
            insert = true, -- Insert emoji (default) or complete its name
            --   ---@type string|table|fun():table
            --   trigger = function()
            --     return { ":" }
            --   end,
          },
          -- should_show_items = function()
          --   return vim.tbl_contains(
          --     -- Enable emoji completion only for git commits and markdown.
          --     -- By default, enabled for all file-types.
          --     { "gitcommit", "markdown" },
          --     vim.o.filetype
          --   )
          -- end,
        },
        dictionary = {
          module = "blink-cmp-dictionary",
          name = "Dict",
          min_keyword_length = 3,
          max_items = 5,
          async = true,
          opts = {
            dictionary_files = { vim.fn.expand("~/g/base/dict/en.dict") },
          },
        },
        tmux = {
          module = "blink-cmp-tmux",
          name = "tmux",
          max_items = 5,
          async = true,
          opts = {
            all_panes = true,
            capture_history = true,
            triggered_only = true,
            trigger_chars = { "." },
          },
        },
        vsnip = {
          name = "vsnip",
          module = "blink-cmp-vsnip",
          opts = {},
        },
      }

      if _G.using_ai() then
        providers.copilot = {
          name = "copilot",
          module = "blink-copilot",
          max_items = 5,
          score_offset = 20,
          async = true,
        }
        providers.supermaven = {
          name = "supermaven",
          module = "blink-cmp-supermaven",
          score_offset = 19,
          async = true,
        }
        providers.minuet = {
          name = "minuet",
          module = "minuet.blink",
          score_offset = 18,
          async = true,
        }
        providers.codeium = {
          name = "codeium",
          module = "blink.compat.source",
          score_offset = 17,
        }
      end

      local config = {
        sources = {
          default = sources,
          providers = providers,
          min_keyword_length = 1,
          per_filetype = {
            gitcommit = function()
              -- Remove codeium from git commit sources to prevent nil offset error
              local git_sources = vim.deepcopy(sources)
              if _G.using_ai() then
                git_sources = vim.tbl_filter(
                  function(source) return source ~= "codeium" end,
                  git_sources
                )
              end
              return git_sources
            end,
          },
        },
        completion = {
          list = {
            selection = {
              preselect = false,
            },
          },
          menu = {
            max_height = 30,
            draw = {
              -- columns = {
              --   { "label", gap = 1 },
              --   -- { "label_description" },
              --   { "kind_icon", "kind", "label_description" },
              -- },
              -- components = {
              --   label = {
              --     width = { fill = true, max = 120 },
              --     text = function(ctx)
              --       return require("colorful-menu").blink_components_text(ctx)
              --     end,
              --     highlight = function(ctx)
              --       return require("colorful-menu").blink_components_highlight(
              --         ctx
              --       )
              --     end,
              --   },
              -- },
              columns = {
                { "label", "label_description", gap = 1 },
                { "kind_icon", gap = 1, "kind" },
                { "source_name" },
              },
              components = {
                label = {
                  width = { fill = true, max = 120 },
                },
                kind = {
                  highlight = kind_highlight,
                  text = kind_text,
                },
                kind_icon = {
                  highlight = kind_highlight,
                },
              },

              treesitter = { "lsp" },
            },
            border = "double",
            -- winblend = 1,
            -- list = {
            --   max_items = 30,
            -- },
          },
          trigger = {
            -- show completion window after backspacing
            show_on_backspace = false,

            -- show completion window after backspacing into a keyword
            show_on_backspace_in_keyword = false,

            -- show completion window after accepting a completion and then
            -- backspacing into a keyword
            show_on_backspace_after_accept = false,

            -- show the completion window after entering insert mode and
            -- backspacing into keyword
            show_on_backspace_after_insert_enter = false,

            show_on_insert = true,

            show_on_blocked_trigger_characters = {},
            show_on_x_blocked_trigger_characters = {},
          },

          -- Show documentation when selecting a completion item
          documentation = { auto_show = false, auto_show_delay_ms = 500 },

          -- Display a preview of the selected item on the current line
          ghost_text = { enabled = false },
        },

        -- appearance = {
        --   use_nvim_cmp_as_default = true,
        --   kind_icons = {
        --     Text = "X",
        --   },
        -- },

        -- Experimental signature help support
        signature = {
          enabled = true,
          window = {
            border = "single",
            show_documentation = false,
          },
        },
        keymap = {
          preset = "none",

          ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
          ["<C-e>"] = { "hide" },
          ["<C-y>"] = { "select_and_accept" },
          ["<CR>"] = { "accept", "fallback" },

          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
          ["<C-n>"] = { "select_next", "fallback_to_mappings" },

          ["<C-b>"] = { "scroll_documentation_up", "fallback" },
          ["<C-f>"] = { "scroll_documentation_down", "fallback" },

          ["<Tab>"] = { "select_next", "fallback" },
          ["<S-Tab>"] = { "select_prev", "fallback" },

          ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        },

        cmdline = {
          enabled = true,
          keymap = { preset = "cmdline" },
          completion = { menu = { auto_show = true } },
        },
      }

      require("blink.cmp").setup(config)
    end,
  },

  -- Emoji picker and insertion via Telescope
  {
    "allaman/emoji.nvim",
    version = "*",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    opts = {},
  },
}
