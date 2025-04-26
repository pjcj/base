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
    lualine_a = { { "mode", padding = { left = 0, right = 1 } } },
    lualine_b = { cwd_basename, "branch" },
    lualine_c = {
      {
        "filename",
        file_status = true, -- Shows file modification status
        path = 1, -- Relative path
        shorting_target = 40,
      },
      { "diff", source = diff_source },
      {
        "diagnostics",
        sources = { "nvim_diagnostic", "ale" },
        symbols = { error = "E", warn = "W", info = "I", hint = "H" },
      },
      -- { navic_component, cond = function() return navic_component() ~= "" end },
    },
    lualine_x = {
      "lsp_status",
    },
    lualine_y = {
      "filetype",
      "encoding",
      {
        "fileformat",
        icons_enabled = true,
        symbols = {
          unix = "LF",
          dos = "CRLF",
          mac = "CR",
        },
      },
      {
        "filesize",
        cond = function()
          return vim.fn.getfsize(vim.fn.expand("%:p")) > 0
        end,
      },
    },
    lualine_z = { "progress", "location" }, -- progress = %, location = line:col
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
  extensions = { "fugitive", "fzf", "lazy", "man", "mason", "oil", "quickfix" },
})
