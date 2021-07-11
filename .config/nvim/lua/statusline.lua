local lsp           = require "feline.providers.lsp"
local vi_mode_utils = require "feline.providers.vi_mode"

local properties = {
  force_inactive = {
    filetypes = {},
    buftypes  = {},
    bufnames  = {},
  },
}

local components = {
  left  = { active = {}, inactive = {} },
  mid   = { active = {}, inactive = {} },
  right = { active = {}, inactive = {} },
}

properties.force_inactive.filetypes = {
  "NvimTree",
  "dbui",
  "packer",
  "startify",
  "fugitive",
  "fugitiveblame",
}

properties.force_inactive.buftypes = {
  "terminal"
}

table.insert(components.left.active, {
  provider = "vi_mode",
  hl = function()
    return {
      name = vi_mode_utils.get_mode_highlight_name(),
      bg   = vi_mode_utils.get_mode_color(),
    }
  end,
  left_sep = function()
    return {
      str = " ",
      hl  = { bg = vi_mode_utils.get_mode_color() },
    }
  end,
  right_sep = {
    "",
    function()
      return {
        str = " ",
        hl  = { bg = vi_mode_utils.get_mode_color() },
      }
    end,
    function()
      return {
        str = "right_filled",
        hl  = { bg = Col_base02, fg = vi_mode_utils.get_mode_color() },
      }
    end,
  },
  icon = "",
})

table.insert(components.left.active, {
  provider  = "file_info",
  type      = "relative",
  hl        = { bg = Col_base02 },
  left_sep  = { str = " ", hl = { bg = Col_base02 } },
  right_sep = {
    str = "right_filled",
    hl  = { bg = Col_base05, fg = Col_base02 },
  },
})

table.insert(components.left.active, {
  provider = "git_branch",
})

table.insert(components.left.active, {
  provider = "git_diff_added",
  hl       = { fg = Col_rgreen }
})

table.insert(components.left.active, {
  provider = "git_diff_changed",
  hl       = { fg = Col_yellow }
})

table.insert(components.left.active, {
  provider  = "git_diff_removed",
  hl        = { fg = Col_red },
  right_sep = {
    " ",
    { str = "right_filled", hl = { bg = Col_base02, fg = Col_base05 } },
  },
})

table.insert(components.left.active, {
  provider = "lsp_client_names",
  hl       = { bg = Col_base02, fg = Col_base01 },
  left_sep = { str = " ", hl = { bg = Col_base02 } },
})

table.insert(components.left.active, {
  provider = "diagnostic_errors",
  enabled  = function() return lsp.diagnostics_exist("Error") end,
  hl       = { bg = Col_base02, fg = "red" },
})

table.insert(components.left.active, {
  provider = "diagnostic_warnings",
  enabled  = function() return lsp.diagnostics_exist("Warning") end,
  hl       = { bg = Col_base02, fg = "yellow" },
})

table.insert(components.left.active, {
  provider = "diagnostic_hints",
  enabled  = function() return lsp.diagnostics_exist("Hint") end,
  hl       = { bg = Col_base02, fg = "cyan" },
})

table.insert(components.left.active, {
  provider = "diagnostic_info",
  enabled  = function() return lsp.diagnostics_exist("Information") end,
  hl       = { bg = Col_base02, fg = "skyblue" },
})

table.insert(components.left.active, {
  provider  = " ",
  hl        = { bg = Col_base02 },
  right_sep = {
    str = "right_filled",
    hl = { bg = Col_base05, fg = Col_base02 },
  },
})

local function file_osinfo()
  local os = vim.bo.fileformat:upper()
  local icon
  if os == "UNIX" then
    icon = " "
  elseif os == "MAC" then
    icon = " "
  else
    icon = " "
  end
  return icon .. os
end

table.insert(components.right.active, {
  provider = file_osinfo,
  hl       = { bg = Col_base02, fg = Col_base01 },
  left_sep = {
    { str = "left_filled", hl = { bg = Col_base05, fg = Col_base02 } },
    { str = " ",           hl = { bg = Col_base02                  } },
  },
})

table.insert(components.right.active, {
  provider = "file_type",
  hl       = { bg = Col_base02, fg = Col_base01 },
  left_sep = { str = " ", hl = { bg = Col_base02 } },
})

table.insert(components.right.active, {
  provider  = "file_encoding",
  hl        = { bg = Col_base02, fg = Col_base01 },
  left_sep  = { str = " ", hl = { bg = Col_base02, fg = Col_base05 } },
  right_sep = { str = " ", hl = { bg = Col_base02                  } },
})

table.insert(components.right.active, {
  provider = "file_size",
  enabled  = function() return vim.fn.getfsize(vim.fn.expand("%:p")) > 0 end,
  left_sep = {
    { str = "left_filled", hl = { bg = Col_base02, fg = Col_base05 } },
    " ",
  },
  right_sep = " ",
})

table.insert(components.right.active, {
  provider = "position",
  hl = function()
    return {
      name = vi_mode_utils.get_mode_highlight_name(),
      bg   = vi_mode_utils.get_mode_color(),
    }
  end,
  left_sep = {
    function()
      return {
        str = "left_filled",
        hl  = { bg = Col_base05, fg = vi_mode_utils.get_mode_color() },
      }
    end,
    function()
      return {
        str = " ",
        hl  = { bg = vi_mode_utils.get_mode_color() },
      }
    end,
  },
})

table.insert(components.left.inactive, {
  provider  = "file_type",
  hl        = { fg = "white", bg = "oceanblue", style = "bold" },
  left_sep  = { str = " ", hl = { fg = "NONE", bg = "oceanblue" } },
  right_sep = {
    { str = " ", hl = { fg = "NONE", bg = "oceanblue" } },
    "right_filled"
  },
})

local colours = {
  bg        = Col_base05,
  black     = Col_base05,
  yellow    = Col_yellow,
  cyan      = Col_cyan,
  oceanblue = Col_dblue,
  green     = Col_green,
  orange    = Col_orange,
  violet    = Col_violet,
  magenta   = Col_magenta,
  white     = Col_base2,
  fg        = Col_base2,
  skyblue   = Col_blue,
  red       = Col_red,
}

local separators = {
  vertical_bar       = "┃",
  vertical_bar_thin  = "│",
  left               = "",
  right              = "",
  block              = "█",
  left_filled        = "",
  right_filled       = "",
  slant_left         = "",
  slant_left_thin    = "",
  slant_right        = "",
  slant_right_thin   = "",
  slant_left_2       = "",
  slant_left_2_thin  = "",
  slant_right_2      = "",
  slant_right_2_thin = "",
  left_rounded       = "",
  left_rounded_thin  = "",
  right_rounded      = "",
  right_rounded_thin = "",
  circle             = "●",
}

local vi_mode_colors = {
  NORMAL        = "green",
  OP            = "green",
  INSERT        = "red",
  VISUAL        = "skyblue",
  BLOCK         = "skyblue",
  REPLACE       = "violet",
  ["V-REPLACE"] = "violet",
  ENTER         = "cyan",
  MORE          = "cyan",
  SELECT        = "orange",
  COMMAND       = "green",
  SHELL         = "green",
  TERM          = "green",
  NONE          = "yellow",
}

require "feline".setup{
  colors         = colours,
  separators     = separators,
  components     = components,
  properties     = properties,
  vi_mode_colors = vi_mode_colors,
}
