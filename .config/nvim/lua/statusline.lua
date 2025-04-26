local l = require("local_defs")
local c = l.colour

-- Custom theme based on Feline colors
local custom_theme = {
  normal = {
    a = { fg = c.base2, bg = c.dgreen, gui = "bold" },
    b = { fg = c.base01, bg = c.base02 },
    c = { fg = c.base2, bg = c.base05 }, -- Adjusted, Feline used multiple backgrounds here
    x = { fg = c.base1, bg = c.base05 }, -- Adjusted
    y = { fg = c.base01, bg = c.base02 },
    z = { fg = c.base2, bg = c.dgreen, gui = "bold" },
  },
  insert = {
    a = { fg = c.base2, bg = c.red, gui = "bold" },
    b = { fg = c.base01, bg = c.base02 },
    z = { fg = c.base2, bg = c.red, gui = "bold" },
  },
  visual = {
    a = { fg = c.base05, bg = c.blue, gui = "bold" }, -- Using c.blue for skyblue
    b = { fg = c.base01, bg = c.base02 },
    z = { fg = c.base05, bg = c.blue, gui = "bold" },
  },
  replace = {
    a = { fg = c.base2, bg = c.violet, gui = "bold" },
    b = { fg = c.base01, bg = c.base02 },
    z = { fg = c.base2, bg = c.violet, gui = "bold" },
  },
  command = {
    a = { fg = c.base05, bg = c.dgreen, gui = "bold" }, -- Same as normal for command mode
    b = { fg = c.base01, bg = c.base02 },
    z = { fg = c.base05, bg = c.dgreen, gui = "bold" },
  },
  inactive = {
    a = { fg = c.base2, bg = c.dblue, gui = "bold" }, -- Matching Feline inactive 'file_type'
    b = { fg = c.base1, bg = c.base02 },
    c = { fg = c.base1, bg = c.base05 },
  },
}

-- Custom function for OS file format icon (replicated from Feline config)
local function file_osinfo()
  local os = vim.bo.fileformat:upper()
  local icon
  if os == "UNIX" then
    icon = " " -- Linux icon
  elseif os == "MAC" then
    icon = " " -- Apple icon
  else
    icon = " " -- Windows icon
  end
  return icon .. os
end

-- Custom function for CWD (last part only)
local function cwd_basename()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

-- Custom function for LSP progress (if lsp-progress is still used)
local function lsp_progress_indicator()
  -- Ensure lsp-progress is loaded and available
  local progress_ok, progress = pcall(require, "lsp-progress")
  if progress_ok and progress.progress then
    return progress.progress()
  end
  return ""
end

-- Custom Navic component (if nvim-navic is still used)
local function navic_component()
  local navic_ok, navic = pcall(require, "nvim-navic")
  if navic_ok and navic.is_available() then
    return navic.get_location()
  end
  return ""
end

require("lualine").setup({
  options = {
    theme = custom_theme,
    -- Use powerline separators like in Feline config
    component_separators = { left = "", right = "" }, -- | thin
    section_separators = { left = "", right = "" }, -- > filled
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
    -- Corresponds roughly to Feline's active[1] left side
    lualine_a = { "mode" },
    lualine_b = { cwd_basename, "branch" },
    lualine_c = {
      {
        "filename",
        file_status = true, -- Shows file modification status
        path = 1, -- Relative path
        shorting_target = 40,
      },
      {
        "diff",
        -- Symbols for git diff status
        symbols = { added = "+", modified = "~", removed = "-" },
        diff_color = {
          added = { fg = c.rgreen },
          modified = { fg = c.yellow },
          removed = { fg = c.red },
        },
      },
    },
    -- Corresponds roughly to Feline's active[1] right side (before middle fill)
    lualine_x = {
      { lsp_progress_indicator, cond = function() return lsp_progress_indicator() ~= "" end },
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        sections = { "error", "warn", "info", "hint" },
        symbols = { error = "E", warn = "W", info = "I", hint = "H" },
        colored = true,
        diagnostics_color = {
          error = { fg = c.c_red },
          warn = { fg = c.c_yellow },
          info = { fg = c.c_sky },
          hint = { fg = c.blue },
        },
      },
      -- { navic_component, cond = function() return navic_component() ~= "" end },
    },
    -- Corresponds roughly to Feline's active[2] (right side)
    lualine_y = {
      file_osinfo,
      "filetype",
      "encoding",
      { "filesize", cond = function() return vim.fn.getfsize(vim.fn.expand("%:p")) > 0 end },
    },
    lualine_z = { "progress", "location" }, -- progress = %, location = line:col
  },
  inactive_sections = {
    -- Simplified inactive statusline, similar to Feline's
    lualine_a = { "filename" },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  },
  tabline = {}, -- Empty tabline, assuming you don't want Lualine to manage tabs
  winbar = {},
  inactive_winbar = {},
  extensions = { "nvim-tree", "toggleterm" }, -- Add extensions as needed
})


-- local lsp = require("feline.providers.lsp")
-- local vi_mode_utils = require("feline.providers.vi_mode")
-- local l = require("local_defs")
-- local c = l.colour

-- local components = {
--   active = {},
--   inactive = {},
-- }

-- table.insert(components.active, {})
-- table.insert(components.active, {})
-- table.insert(components.inactive, {})

-- table.insert(components.active[1], {
--   provider = "vi_mode",
--   hl = function()
--     return {
--       name = vi_mode_utils.get_mode_highlight_name(),
--       bg = vi_mode_utils.get_mode_color(),
--     }
--   end,
--   left_sep = function()
--     return {
--       str = " ",
--       hl = { bg = vi_mode_utils.get_mode_color() },
--     }
--   end,
--   right_sep = {
--     "",
--     function()
--       return {
--         str = " ",
--         hl = { bg = vi_mode_utils.get_mode_color() },
--       }
--     end,
--     function()
--       return {
--         str = "right_filled",
--         hl = { bg = c.base02, fg = vi_mode_utils.get_mode_color() },
--       }
--     end,
--   },
--   icon = "",
-- })

-- table.insert(components.active[1], {
--   provider = function()
--     return vim.fn.getcwd():match("([^/]+)$") .. " "
--   end,
--   hl = { bg = c.base02, fg = c.base01 },
--   left_sep = { str = " ", hl = { bg = c.base02 } },
--   right_sep = {
--     {
--       str = "right_filled",
--       hl = { bg = c.base05, fg = c.base02 },
--     },
--     " ",
--   },
--   truncate_hide = true,
-- })

-- local file_info = {
--   provider = {
--     name = "file_info",
--     opts = {
--       type = "relative",
--       file_modified_icon = "",
--     },
--     hl = { bg = c.base02 },
--     left_sep = { str = " ", hl = { bg = c.base02 } },
--     right_sep = {
--       str = "right_filled",
--       hl = { bg = c.base05, fg = c.base02 },
--     },
--   },
--   short_provider = {
--     name = "file_info",
--     opts = {
--       type = "relative-short",
--       file_modified_icon = "",
--     },
--     hl = { bg = c.base02 },
--     left_sep = { str = " ", hl = { bg = c.base02 } },
--     right_sep = {
--       str = "right_filled",
--       hl = { bg = c.base05, fg = c.base02 },
--     },
--   },
-- }

-- table.insert(components.active[1], file_info)

-- table.insert(components.active[1], {
--   provider = "git_branch",
--   left_sep = { str = " ", hl = { bg = c.base05 } },
-- })
-- table.insert(components.active[1], {
--   provider = "git_diff_added",
--   hl = { fg = c.rgreen },
--   icon = " +",
-- })

-- table.insert(components.active[1], {
--   provider = "git_diff_changed",
--   hl = { fg = c.yellow },
--   icon = " ~",
-- })

-- table.insert(components.active[1], {
--   provider = "git_diff_removed",
--   hl = { fg = c.red },
--   icon = " -",
--   right_sep = {
--     { str = " ", always_visible = true },
--     {
--       str = "right_filled",
--       hl = { bg = c.base02, fg = c.base05 },
--       always_visible = true,
--     },
--   },
-- })

-- table.insert(components.active[1], {
--   provider = "lsp_client_names",
--   hl = { bg = c.base02, fg = c.base01 },
--   left_sep = { str = " ", hl = { bg = c.base02 } },
--   right_sep = { str = " ", hl = { bg = c.base02 } },
--   truncate_hide = true,
-- })

-- table.insert(components.active[1], {
--   provider = function()
--     return require("lsp-progress").progress() .. " "
--   end,
--   hl = { bg = c.base02, fg = c.base01 },
--   right_sep = {
--     {
--       str = "right_filled",
--       hl = { bg = c.base05, fg = c.base02 },
--     },
--   },
--   truncate_hide = true,
-- })

-- local severity = vim.diagnostic.severity

-- table.insert(components.active[1], {
--   provider = "diagnostic_errors",
--   enabled = function()
--     return lsp.diagnostics_exist(severity.ERROR)
--   end,
--   hl = { bg = c.base05, fg = c.c_red },
--   icon = " E ",
-- })

-- table.insert(components.active[1], {
--   provider = "diagnostic_warnings",
--   enabled = function()
--     return lsp.diagnostics_exist(severity.WARN)
--   end,
--   hl = { bg = c.base05, fg = c.c_yellow },
--   icon = " W ",
-- })

-- table.insert(components.active[1], {
--   provider = "diagnostic_info",
--   enabled = function()
--     return lsp.diagnostics_exist(severity.INFO)
--   end,
--   hl = { bg = c.base05, fg = c.c_sky },
--   icon = " I ",
-- })

-- table.insert(components.active[1], {
--   provider = "diagnostic_hints",
--   enabled = function()
--     return lsp.diagnostics_exist(severity.HINT)
--   end,
--   hl = { bg = c.base05, fg = c.blue },
--   icon = " H ",
-- })

-- table.insert(components.active[1], {
--   provider = " ",
--   hl = { bg = c.base05 },
--   right_sep = {
--     str = "right_filled",
--     hl = { bg = c.base02, fg = c.base05 },
--   },
-- })

-- local navic = require("nvim-navic")
-- table.insert(components.active[1], {
--   provider = function()
--     return navic.get_location() .. " "
--   end,
--   enabled = function()
--     return navic.is_available()
--   end,
--   hl = { bg = c.base02, fg = "yellow" },
--   left_sep = { str = " ", hl = { bg = c.base02 } },
--   right_sep = {
--     {
--       str = "right_filled",
--       hl = { bg = c.base05, fg = c.base02 },
--     },
--     " ",
--   },
--   truncate_hide = true,
-- })

-- local function file_osinfo()
--   local os = vim.bo.fileformat:upper()
--   local icon
--   if os == "UNIX" then
--     icon = " "
--   elseif os == "MAC" then
--     icon = " "
--   else
--     icon = " "
--   end
--   return icon .. os
-- end

-- table.insert(components.active[2], {
--   provider = file_osinfo,
--   hl = { bg = c.base02, fg = c.base01 },
--   left_sep = {
--     { str = "left_filled", hl = { bg = c.base05, fg = c.base02 } },
--     { str = " ", hl = { bg = c.base02 } },
--   },
--   truncate_hide = true,
-- })

-- table.insert(components.active[2], {
--   provider = "file_type",
--   hl = { bg = c.base02, fg = c.base01 },
--   left_sep = { str = " ", hl = { bg = c.base02 } },
--   truncate_hide = true,
-- })

-- table.insert(components.active[2], {
--   provider = "file_encoding",
--   hl = { bg = c.base02, fg = c.base01 },
--   left_sep = { str = " ", hl = { bg = c.base02, fg = c.base05 } },
--   right_sep = { str = " ", hl = { bg = c.base02 } },
--   truncate_hide = true,
-- })

-- table.insert(components.active[2], {
--   provider = "file_size",
--   enabled = function()
--     return vim.fn.getfsize(vim.fn.expand("%:p")) > 0
--   end,
--   left_sep = {
--     { str = "left_filled", hl = { bg = c.base02, fg = c.base05 } },
--     " ",
--   },
--   right_sep = " ",
-- })

-- table.insert(components.active[2], {
--   provider = "position",
--   hl = function()
--     return {
--       name = vi_mode_utils.get_mode_highlight_name(),
--       bg = vi_mode_utils.get_mode_color(),
--     }
--   end,
--   left_sep = {
--     function()
--       return {
--         str = "left_filled",
--         hl = { bg = c.base05, fg = vi_mode_utils.get_mode_color() },
--       }
--     end,
--     function()
--       return {
--         str = " ",
--         hl = { bg = vi_mode_utils.get_mode_color() },
--       }
--     end,
--   },
-- })

-- table.insert(components.inactive[1], {
--   provider = "file_type",
--   hl = { fg = "white", bg = "oceanblue", style = "bold" },
--   left_sep = { str = " ", hl = { fg = "NONE", bg = "oceanblue" } },
--   right_sep = {
--     { str = " ", hl = { fg = "NONE", bg = "oceanblue" } },
--     "right_filled",
--   },
-- })

-- table.insert(components.inactive[1], file_info)

-- table.insert(components.inactive[1], {
--   provider = "git_branch",
--   left_sep = { str = " ", hl = { bg = c.base05 } },
-- })

-- local colours = {
--   bg = c.base05,
--   black = c.base05,
--   yellow = c.yellow,
--   cyan = c.cyan,
--   oceanblue = c.dblue,
--   green = c.green,
--   orange = c.orange,
--   violet = c.violet,
--   magenta = c.magenta,
--   white = c.base2,
--   fg = c.base2,
--   skyblue = c.blue,
--   red = c.red,
-- }

-- local separators = {
--   vertical_bar = "┃",
--   vertical_bar_thin = "│",
--   left = "",
--   right = "",
--   block = "█",
--   left_filled = "",
--   right_filled = "",
--   slant_left = "",
--   slant_left_thin = "",
--   slant_right = "",
--   slant_right_thin = "",
--   slant_left_2 = "",
--   slant_left_2_thin = "",
--   slant_right_2 = "",
--   slant_right_2_thin = "",
--   left_rounded = "",
--   left_rounded_thin = "",
--   right_rounded = "",
--   right_rounded_thin = "",
--   circle = "●",
-- }

-- local vi_mode_colors = {
--   NORMAL = c.dgreen,
--   OP = c.dgreen,
--   INSERT = "red",
--   VISUAL = "skyblue",
--   BLOCK = "skyblue",
--   REPLACE = "violet",
--   ["V-REPLACE"] = "violet",
--   ENTER = "cyan",
--   MORE = "cyan",
--   SELECT = "orange",
--   COMMAND = c.dgreen,
--   SHELL = c.dgreen,
--   TERM = c.dgreen,
--   NONE = "yellow",
-- }

-- require("feline").setup({
--   theme = colours,
--   separators = separators,
--   components = components,
--   vi_mode_colors = vi_mode_colors,
-- })
