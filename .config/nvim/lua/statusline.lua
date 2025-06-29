local l = require("local_defs")
local c = l.colour

local custom_theme = {
  normal = {
    a = { fg = c.base2, bg = c.dgreen, gui = "bold" },
    b = { fg = c.lviolet, bg = c.base02 },
    c = { fg = c.base2, bg = c.base05 },
    x = { fg = c.base1, bg = c.base05 },
    y = { fg = c.lviolet, bg = c.base02 },
    z = { fg = c.base2, bg = c.dgreen, gui = "bold" },
  },
  insert = {
    a = { fg = c.base2, bg = c.red, gui = "bold" },
    b = { fg = c.base01, bg = c.base02 },
    z = { fg = c.base2, bg = c.red, gui = "bold" },
  },
  visual = {
    a = { fg = c.base2, bg = c.blue, gui = "bold" },
    b = { fg = c.base01, bg = c.base02 },
    z = { fg = c.base2, bg = c.blue, gui = "bold" },
  },
  replace = {
    a = { fg = c.base2, bg = c.violet, gui = "bold" },
    b = { fg = c.base01, bg = c.base02 },
    z = { fg = c.base2, bg = c.violet, gui = "bold" },
  },
  command = {
    a = { fg = c.base2, bg = c.dgreen, gui = "bold" },
    b = { fg = c.base01, bg = c.base02 },
    z = { fg = c.base2, bg = c.dgreen, gui = "bold" },
  },
  inactive = {
    a = { fg = c.base2, bg = c.dblue, gui = "bold" },
    b = { fg = c.base1, bg = c.base02 },
    c = { fg = c.base1, bg = c.base05 },
  },
}

-- Helper function to check if there are multiple windows
local function has_multiple_windows()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local normal_win_count = 0

  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    -- Only count normal windows (not floating, not external)
    if config.relative == "" then
      normal_win_count = normal_win_count + 1
    end
  end

  return normal_win_count > 1
end

-- Custom function for conditional filename display
local function conditional_filename()
  if has_multiple_windows() then
    return "" -- Don't show filename in statusline when there are multiple windows
  else
    return vim.fn.expand("%:t") -- Show just the filename when single window
  end
end

-- Function to get aider model info
local function get_aider_info()
  local bufname = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype

  -- Check if this is an aider buffer
  if
    filetype == "aider"
    or string.match(bufname, "aider")
    or string.match(bufname, "Aider")
  then
    local model = nil

    -- Try to get model from nvim-aider plugin configuration
    local ok, nvim_aider = pcall(require, "nvim_aider")
    if ok and nvim_aider then
      local config = nvim_aider.config or {}
      local args = config.args or {}

      -- Look for --model in the args
      for i, arg in ipairs(args) do
        if arg == "--model" and args[i + 1] then
          model = args[i + 1]
          break
        end
      end
    end

    -- Try to get from buffer variables
    if not model then
      model = vim.b.aider_model or vim.g.aider_model
    end

    -- Try to read from running aider process
    if not model then
      local cmd = "ps aux 2>/dev/null | grep '[a]ider' | "
        .. "grep -o '\\--model [^ ]*' | head -1 | cut -d' ' -f2 2>/dev/null"
      local handle = io.popen(cmd)
      if handle then
        local result = handle:read("*a")
        handle:close()
        if result and result ~= "" then
          model = result:gsub("%s+", "")
        end
      end
    end

    -- Try to read from aider config files
    if not model then
      local config_paths = {
        ".aider.conf.yml",
        os.getenv("HOME") .. "/.aider.conf.yml",
        ".aiderrc",
        os.getenv("HOME") .. "/.aiderrc",
      }

      for _, config_path in ipairs(config_paths) do
        local file = io.open(config_path, "r")
        if file then
          local content = file:read("*a")
          file:close()
          -- Look for model specification in YAML config
          model = content:match("model:%s*([%w%-%./:]+)")
          if model and not model:match("^#") then
            break
          else
            model = nil
          end
        end
      end
    end

    -- Extract just the model name from full model paths like
    -- "openai/claude-sonnet-4"
    if model then
      local clean_model = model:match("([^/]+)$") or model
      return "aider:" .. clean_model
    end

    return "aider:default"
  end
  return nil
end

local function winbar_component(active_colors)
  return {
    function()
      -- Check if this is an aider window first
      local aider_info = get_aider_info()
      if aider_info then
        return aider_info
      end

      if has_multiple_windows() then
        return vim.fn.expand("%:~:.") -- Show relative path
      else
        return "" -- Don't show winbar when single window
      end
    end,
    padding = { left = 1, right = 1 },
    color = function()
      local aider_info = get_aider_info()
      if aider_info then
        return { fg = c.lgreen, bg = c.base05 } -- Special color for aider windows
      elseif has_multiple_windows() then
        return active_colors or { fg = c.base1, bg = c.base05 }
      else
        return {}
      end
    end,
  }
end

-- Custom function for CWD (last part only)
local function cwd_basename()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

-- Custom Navic component
-- local function navic_component()
--   local navic_ok, navic = pcall(require, "nvim-navic")
--   if navic_ok and navic.is_available() then
--     return navic.get_location()
--   end
--   return ""
-- end

local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

local function mcphub_component_definition()
  local ok, mcphub_ext_component = pcall(require, "mcphub.extensions.lualine")
  if ok and mcphub_ext_component then
    return {
      mcphub_ext_component,
      separator = "",
      padding = { left = 0, right = 0 },
      -- color = { fg = c.red, bg = c.base02 },
    }
  else
    return {
      function()
        return " ﮿"
      end,
      separator = "",
      padding = { left = 0, right = 0 },
    }
  end
end

-- local function avante_rag_status()
--   local ok, _ = pcall(require, "avante.api")
--   if not ok then
--     return ""
--   end

--   -- Check if rag service is enabled and get its status
--   local config = require("avante.config")
--   if not config.rag_service or not config.rag_service.enabled then
--     return ""
--   end

--   -- Try to get rag service status
--   local rag_ok, rag_status = pcall(function()
--     local rag_service = require("avante.rag_service")
--     if rag_service and rag_service.get_rag_service_status then
--       return rag_service.get_rag_service_status()
--     end
--     return "unknown"
--   end)

--   if not rag_ok then
--     return " ⚠️" -- Default icon when status can't be determined
--   end

--   -- Return status with appropriate icon and color
--   local status_icons = {
--     running = " 🏃",
--     stopped = " 🛑",
--     ready = " ✅",
--     indexing = " ⏳",
--     error = " ❗",
--     disabled = " 🚫",
--     unknown = " ❓",
--   }

--   return status_icons[rag_status] or " 🔍"
-- end

require("lualine").setup({
  options = {
    theme = custom_theme,
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = true, -- Use a single global statusline
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = { { "mode", padding = { left = 0, right = 0 } } },
    lualine_b = {
      { cwd_basename, separator = "", padding = { left = 1, right = 1 } },
      { "branch", padding = { left = 0, right = 0 } },
    },
    lualine_c = {
      {
        conditional_filename,
        separator = "",
        padding = { left = 1, right = 0 },
      },
      {
        "diff",
        separator = "",
        padding = { left = 1, right = 0 },
        source = diff_source,
      },
      {
        "diagnostics",
        padding = { left = 1, right = 0 },
        sources = { "nvim_diagnostic", "ale" },
        symbols = { error = "E", warn = "W", info = "I", hint = "H" },
      },
      -- { navic_component, cond = function() return navic_component() ~= "" end },
    },
    lualine_x = {
      {
        "copilot",
        separator = "",
        padding = { left = 0, right = 1 },
        symbols = {
          status = {
            hl = {
              enabled = c.rgreen,
              sleep = c.base1,
              disabled = c.base01,
              warning = c.yellow,
              unknown = c.red,
            },
          },
          spinners = "bouncing_ball",
          spinner_color = c.peach,
        },
        show_colors = true,
        show_loading = true,
      },
      -- {
      --   function()
      --     local ok, minuet_lualine = pcall(require, "minuet.lualine")
      --     if ok then
      --       return minuet_lualine()
      --     end
      --     return ""
      --   end,
      --   -- the following is the default configuration
      --   -- the name displayed in the lualine. Set to "provider", "model" or "both"
      --   -- display_name = 'both',
      --   -- separator between provider and model name for option "both"
      --   -- provider_model_separator = ':',
      --   -- whether show display_name when no completion requests are active
      --   display_on_idle = true,
      --   cond = function()
      --     local ok, _ = pcall(require, "minuet.lualine")
      --     return ok
      --   end,
      -- },
      -- require("vectorcode.integrations").lualine({ show_job_count = true }),
      -- {
      --   avante_rag_status,
      --   separator = "",
      --   padding = { left = 0, right = 1 },
      --   color = function()
      --     local rag_ok, rag_status = pcall(function()
      --       local rag_service = require("avante.rag_service")
      --       if rag_service and rag_service.get_rag_service_status then
      --         return rag_service.get_rag_service_status()
      --       end
      --       return "unknown"
      --     end)

      --     if not rag_ok then
      --       return { fg = c.base1 }
      --     end

      --     local status_colors = {
      --       running = { fg = c.rgreen },
      --       stopped = { fg = c.red },
      --       ready = { fg = c.rgreen },
      --       indexing = { fg = c.yellow },
      --       error = { fg = c.red },
      --       disabled = { fg = c.base01 },
      --       unknown = { fg = c.base1 },
      --     }

      --     return status_colors[rag_status] or { fg = c.base1 }
      --   end,
      --   cond = function()
      --     local config_ok, config = pcall(require, "avante.config")
      --     return config_ok and config.rag_service and config.rag_service.enabled
      --   end,
      -- },
      mcphub_component_definition(),
      {
        "lsp_status",
        padding = { left = 1, right = 1 },
      },
    },
    lualine_y = {
      {
        "filetype",
        separator = "",
        padding = { left = 0, right = 1 },
      },
      {
        "encoding",
        separator = "",
        padding = { left = 0, right = 1 },
      },
      {
        "fileformat",
        separator = "",
        padding = { left = 0, right = 1 },
        icons_enabled = true,
        symbols = {
          unix = "LF",
          dos = "CRLF",
          mac = "CR",
        },
      },
      {
        "filesize",
        padding = { left = 0, right = 1 },
        cond = function()
          return vim.fn.getfsize(vim.fn.expand("%:p")) > 0
        end,
      },
    },
    lualine_z = {
      { "progress", separator = "", padding = { left = 0, right = 1 } },
      { "location", padding = { left = 0, right = 0 } },
    }, -- progress = %, location = line:col
  },
  inactive_sections = {
    -- Simplified inactive statusline
    lualine_a = { "filename" },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  },
  tabline = {},
  winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      winbar_component({ fg = c.pyellow, bg = c.base05 }),
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  inactive_winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      winbar_component({ fg = c.base01, bg = c.base02 }),
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  extensions = {
    "avante",
    "fugitive",
    "fzf",
    "lazy",
    "man",
    "mason",
    "oil",
    "quickfix",
  },
})
