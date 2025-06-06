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

-- Custom function for CWD (last part only)
local function cwd_basename()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

-- Custom Navic component
local function navic_component()
  local navic_ok, navic = pcall(require, "nvim-navic")
  if navic_ok and navic.is_available() then
    return navic.get_location()
  end
  return ""
end

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
        "filename",
        separator = "",
        padding = { left = 1, right = 0 },
        file_status = true, -- Shows file modification status
        newfile_status = true,
        path = 1, -- Relative path
        shorting_target = 40,
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
  winbar = {},
  inactive_winbar = {},
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
