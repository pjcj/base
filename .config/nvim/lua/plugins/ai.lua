-- AI-related plugins for Neovim
-- This file contains all AI completion and assistance plugins

return {
  -- Free AI code completion (alternative: neocodeium)
  {
    "Exafunction/codeium.nvim",
    enabled = _G.using_ai(),
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {},
  },

  -- Fast AI code completion with local context awareness
  {
    "supermaven-inc/supermaven-nvim",
    enabled = _G.using_ai(),
    opts = {
      disable_inline_completion = true,
      disable_keymaps = true,
    },
  },

  -- GitHub Copilot integration with Claude Sonnet 4 model
  {
    "zbirenbaum/copilot.lua",
    enabled = _G.using_ai(),
    cmd = "Copilot",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      copilot_model = "claude-sonnet-4",
      filetypes = {
        ["*"] = true, -- enable copilot for all filetypes
      },
    },
  },

  -- Display Copilot status in lualine statusline
  {
    "AndreM222/copilot-lualine",
    enabled = _G.using_ai(),
  },

  -- AI-powered coding assistant with chat interface and MCP tools
  {
    "olimorris/codecompanion.nvim",
    version = "*",
    enabled = _G.using_ai(),
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "claude37sonnet",
            tools = {
              opts = {
                wait_timeout = 600000, -- 10 minutes
                auto_submit_errors = true, -- Automatically submit errors to the LLM
                auto_submit_success = true, -- Automatically submit successful results to the LLM
                default_tools = {
                  "full_stack_dev",
                  "next_edit_suggestion",
                  "mcp",
                },
              },
            },
            keymaps = {
              completion = {
                modes = {
                  i = "<C-n>",
                },
              },
            },
          },
          inline = { adapter = "claude37sonnet" },
          cmd = { adapter = "claude37sonnet" },
        },
        display = {
          chat = {
            -- intro_message = "Welcome to CodeCompanion ✨! Press ? for options",
            show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
            separator = "─", -- The separator between the different messages in the chat buffer
            show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
            show_settings = false, -- Show LLM settings at the top of the chat buffer?
            show_token_count = true, -- Show the token count for each response?
            start_in_insert_mode = true, -- Open the chat buffer in insert mode?
            border = "rounded", -- Add border styling
            window = {
              width = 120,
            },
          },
        },
        adapters = {
          http = {
            claude4sonnet = function()
              return require("codecompanion.adapters").extend("copilot", {
                schema = {
                  model = {
                    default = "claude-sonnet-4",
                  },
                  -- max_tokens = {
                  --   default = 81920,
                  -- },
                },
              })
            end,
            claude37sonnet = function()
              return require("codecompanion.adapters").extend("copilot", {
                schema = {
                  model = {
                    default = "claude-3.7-sonnet",
                  },
                  -- max_tokens = {
                  --   default = 81920,
                  -- },
                },
              })
            end,
            gpt5 = function()
              return require("codecompanion.adapters").extend("copilot", {
                schema = {
                  model = {
                    default = "gpt-5",
                  },
                },
              })
            end,
            gemini25 = function()
              return require("codecompanion.adapters").extend("gemini", {
                -- give this adapter a different name to differentiate it from the
                -- default gemini adapter
                name = "gemini25",
                schema = {
                  model = {
                    default = "gemini-2.5-pro",
                    -- default = "gemini-2.5-pro-preview-06-05",
                  },
                  -- num_ctx = {
                  --   default = 16384,
                  -- },
                  -- num_predict = {
                  --   default = -1,
                  -- },
                },
              })
            end,
          },
        },
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              show_result_in_chat = true, -- Show mcp tool results in chat
              make_vars = true, -- Convert resources to #variables
              make_slash_commands = true, -- Add prompts as /slash commands
            },
          },
        },
      })
      local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanionChatModel",
        group = group,
        callback = function(event)
          vim.api.nvim_buf_set_name(
            event.data.bufnr,
            string.format(
              "[CodeCompanion] %d (%s)",
              event.data.bufnr,
              event.data.model
            )
          )
        end,
      })
    end,
  },

  -- Multi-provider AI completion with Gemini Flash model
  {
    "milanglacier/minuet-ai.nvim",
    enabled = _G.using_ai(),
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- Setup notification filter to prevent spam from API errors
      require("notification_filter").setup()

      require("minuet").setup({
        provider = "gemini",
        provider_options = {
          gemini = {
            model = "gemini-1.5-flash",
            stream = true, -- streaming responses are generally faster
            -- optional = {
            --   generationConfig = {
            --     maxOutputTokens = 256,
            --     -- When using `gemini-2.5-flash`, it is recommended to entirely
            --     -- disable thinking for faster completion retrieval.
            --     thinkingConfig = {
            --       thinkingBudget = 0,
            --     },
            --   },
            --   safetySettings = {
            --     {
            --       -- HARM_CATEGORY_HATE_SPEECH,
            --       -- HARM_CATEGORY_HARASSMENT
            --       -- HARM_CATEGORY_SEXUALLY_EXPLICIT
            --       category = "HARM_CATEGORY_DANGEROUS_CONTENT",
            --       -- BLOCK_NONE
            --       threshold = "BLOCK_ONLY_HIGH",
            --     },
            --   },
            -- },
          },
        },
      })
    end,
  },

  -- Model Context Protocol hub for AI tools integration
  {
    "ravitemer/mcphub.nvim",
    enabled = _G.using_ai(),
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = "MCPHub", -- lazy load by default
    build = "npm install -g mcp-hub@latest",
    config = function()
      require("mcphub").setup({
        log = {
          level = vim.log.levels.INFO, -- DEBUG, INFO, WARN, ERROR
        },
        extensions = {
          avante = {
            auto_approve_mcp_tool_calls = false, -- auto approve mcp tool calls
          },
        },
      })
    end,
  },

  -- AI-powered coding assistant with inline editing and chat
  {
    "yetone/avante.nvim",
    enabled = _G.using_ai(),
    version = false, -- never set this to "*"
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- the below dependencies are optional
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      "ravitemer/mcphub.nvim",
      "MeanderingProgrammer/render-markdown.nvim",
      -- {
      --   -- support for image pasting
      --   "HakonHarnes/img-clip.nvim",
      --   event = "VeryLazy",
      --   opts = {
      --     -- recommended settings
      --     default = {
      --       embed_image_as_base64 = false,
      --       prompt_for_file_name = false,
      --       -- drag_and_drop = {
      --       --   insert_mode = true,
      --       -- },
      --       use_absolute_path = true, -- required for Windows
      --     },
      --   },
      -- },
    },
    opts = {
      provider = "copilot_claude_sonnet_4",
      providers = {
        copilot_claude_sonnet_3_7 = {
          __inherited_from = "copilot",
          model = "claude-3.7-sonnet",
          timeout = 60000,
          extra_request_body = {
            max_tokens = 200000,
          },
        },
        copilot_claude_sonnet_4 = {
          __inherited_from = "copilot",
          model = "claude-sonnet-4",
          timeout = 60000,
          extra_request_body = {
            max_tokens = 2000000,
          },
        },
        copilot_gpt_5 = {
          __inherited_from = "copilot",
          model = "gpt-5",
          timeout = 60000,
          extra_request_body = {
            max_tokens = 128000,
          },
        },
        copilot_gemini = {
          __inherited_from = "copilot",
          model = "gemini-2.5-pro",
          timeout = 60000,
          extra_request_body = {
            max_tokens = 2097152,
          },
        },
        perplexity_llama_3_1_sonar_large_128k_online = {
          __inherited_from = "openai",
          api_key_name = "PPLX_API_KEY",
          endpoint = "https://api.perplexity.ai",
          model = "llama-3.1-sonar-large-128k-online",
          timeout = 60000,
          extra_request_body = {
            max_tokens = 128000,
          },
        },
      },
      thinking = {
        type = "enabled",
        budget_tokens = 50000, -- Increased thinking budget for maximum reasoning
      },
      dual_boost = {
        enabled = false,
        first_provider = "copilot_claude_sonnet_3_7",
        second_provider = "copilot_gemini",
        timeout = 60000, -- timeout in milliseconds
      },
      rag_service = {
        enabled = false,
        host_mount = os.getenv("HOME") .. "/g",
        runner = "docker",
        llm = {
          provider = "ollama",
          endpoint = "http://host.docker.internal:11434",
          model = "qwen2.5-coder",
          -- model = "llama3",
          api_key = "",
        },
        embed = {
          provider = "ollama",
          endpoint = "http://host.docker.internal:11434",
          model = "mxbai-embed-large",
          -- model = "nomic-embed-text",
          api_key = "",
        },
      },

      {
        selector = { provider = "telescope" },
      },

      -- system_prompt as function ensures LLM always has latest MCP server
      -- state - evaluated for every message, even in existing chats.
      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub:get_active_servers_prompt()
      end,
      -- using a function prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "avante*", "Avante*" },
        callback = function() vim.wo.colorcolumn = "" end,
      })
    end,
  },

  -- AI pair programming with aider integration
  {
    "GeorgesAlkhouri/nvim-aider",
    enabled = _G.using_ai(),
    cmd = "Aider",
    dependencies = {
      {
        "folke/snacks.nvim",
        priority = 1000,
        -- lazy = false,
        opts = {
          -- bigfile = { enabled = true },
          -- dashboard = { enabled = true },
          -- explorer = { enabled = true },
          -- indent = { enabled = true },
          -- input = { enabled = true },
          picker = { enabled = true },
          -- notifier = { enabled = true },
          -- quickfile = { enabled = true },
          -- scope = { enabled = true },
          -- scroll = { enabled = true },
          -- statuscolumn = { enabled = true },
          -- words = { enabled = true },
        },
      },
      "catppuccin/nvim",
      "nvim-tree/nvim-tree.lua",
      {
        "nvim-neo-tree/neo-tree.nvim",
        optional = true,
        opts = function(_, opts) require("nvim_aider.neo_tree").setup(opts) end,
      },
    },
    config = function()
      require("nvim_aider").setup({
        args = {
          "--openai-api-base",
          "https://api.githubcopilot.com",
          "--openai-api-key",
          "$(op read op://Private/GitHub/copilot-api-key)",
          "--model",
          "openai/claude-sonnet-4",
          "--weak-model",
          "openai/claude-3.7-sonnet",
          -- "--model", "openai/gpt-4o",
          -- "--model", "openai/gpt-4.1",
          -- "--weak-model", "openai/gpt-4o-mini",
          -- "--model", "openai/gemini-2.5-pro",
          "--no-show-model-warnings",
          "--edit-format",
          "udiff",
          -- "--multiline",
          "--show-diffs",
        },
        -- args = {
        --   "--no-auto-commits",
        --   "--pretty",
        --   "--stream",
        -- },
        -- Automatically reload buffers changed by Aider (requires vim.o.autoread = true)
        auto_reload = true,
        -- Theme colors (automatically uses Catppuccin flavor if available)
        -- theme = {
        --   user_input_color = "#a6da95",
        --   tool_output_color = "#8aadf4",
        --   tool_error_color = "#ed8796",
        --   tool_warning_color = "#eed49f",
        --   assistant_output_color = "#c6a0f6",
        --   completion_menu_color = "#cad3f5",
        --   completion_menu_bg_color = "#24273a",
        --   completion_menu_current_color = "#181926",
        --   completion_menu_current_bg_color = "#f4dbd6",
        -- },
        -- -- snacks.picker.layout.Config configuration
        -- picker_cfg = {
        --   preset = "vscode",
        -- },
        -- -- Other snacks.terminal.Opts options
        -- config = {
        --   os = { editPreset = "nvim-remote" },
        --   gui = { nerdFontsVersion = "3" },
        -- },
        -- win = {
        --   wo = { winbar = "Aider" },
        --   style = "nvim_aider",
        --   position = "right",
        -- },
      })
    end,
  },

  -- Claude Code integration for AI-powered development
  {
    "coder/claudecode.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = true,
    opts = {
      auto_start = true,
      terminal = {
        terminal_cmd = "~/.claude/local/claude",
        -- provider = "native",
        provider = {
          -- setup = function(config) end,
          -- open = function(cmd_string, env_table, effective_config, focus) end,
          -- close = function() end,
          -- simple_toggle = function(cmd_string, env_table, effective_config) end,
          -- focus_toggle = function(cmd_string, env_table, effective_config) end,
          setup = function() end,
          open = function() end,
          close = function() end,
          simple_toggle = function() end,
          focus_toggle = function() end,
          get_active_bufnr = function() end,
          is_available = function() return true end,
        },
        split_width_percentage = 0.4,
      },
    },
    keys = {
      {
        "<leader> ..",
        "<cmd>ClaudeCode<cr><cmd>horizontal wincmd =<cr>",
        desc = "Toggle Claude",
      },
      { "<leader> .f", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader> .r", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      {
        "<leader> .c",
        "<cmd>ClaudeCode --continue<cr>",
        desc = "Continue Claude",
      },
      {
        "<leader> .b",
        "<cmd>ClaudeCodeAdd %<cr>",
        desc = "Add current buffer",
      },
      {
        "<leader> .s",
        "<cmd>ClaudeCodeSend<cr>",
        mode = "v",
        desc = "Send to Claude",
      },
      {
        "<leader> .s",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      -- Diff management
      { "<leader> .a", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader> .d", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },

  -- FZF integration for Claude Code file selection
  {
    "pittcat/claude-fzf.nvim",
    dependencies = {
      "ibhagwan/fzf-lua",
      "coder/claudecode.nvim",
    },
    opts = {
      auto_context = true,
      batch_size = 10,
    },
    cmd = {
      "ClaudeFzf",
      "ClaudeFzfFiles",
      "ClaudeFzfGrep",
      "ClaudeFzfBuffers",
      "ClaudeFzfGitFiles",
      "ClaudeFzfDirectory",
    },
    keys = {
      { "<leader>cf", "<cmd>ClaudeFzfFiles<cr>", desc = "Claude: Add files" },
      {
        "<leader>cg",
        "<cmd>ClaudeFzfGrep<cr>",
        desc = "Claude: Search and add",
      },
      {
        "<leader>cb",
        "<cmd>ClaudeFzfBuffers<cr>",
        desc = "Claude: Add buffers",
      },
      {
        "<leader>cgf",
        "<cmd>ClaudeFzfGitFiles<cr>",
        desc = "Claude: Add Git files",
      },
      {
        "<leader>cd",
        "<cmd>ClaudeFzfDirectory<cr>",
        desc = "Claude: Add directory files",
      },
    },
  },

  -- Claude Code conversation history browser
  {
    "pittcat/claude-fzf-history.nvim",
    dependencies = { "ibhagwan/fzf-lua" },
    opts = {},
    cmd = { "ClaudeHistory", "ClaudeHistoryDebug" },
    keys = {
      { "<leader>ch", "<cmd>ClaudeHistory<cr>", desc = "Claude History" },
    },
  },

  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Recommended for better prompt input, and required to use
      -- `opencode.nvim`'s embedded terminal — otherwise optional
      { "folke/snacks.nvim", opts = { input = { enabled = true } } },
    },
    config = function()
      vim.g.opencode_opts = {
        terminal = {
          env = {
            -- Use our custom theme instead of the default "system" theme
            OPENCODE_THEME = "solarized-pjcj",
          },
        },
      }

      vim.opt.autoread = true -- Required for `opts.auto_reload`
    end,
  },
}
