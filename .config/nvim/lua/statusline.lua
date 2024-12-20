local lsp = require("feline.providers.lsp")
local vi_mode_utils = require("feline.providers.vi_mode")
local l = require("local_defs")
local c = l.colour

local components = {
  active = {},
  inactive = {},
}

table.insert(components.active, {})
table.insert(components.active, {})
table.insert(components.inactive, {})

table.insert(components.active[1], {
  provider = "vi_mode",
  hl = function()
    return {
      name = vi_mode_utils.get_mode_highlight_name(),
      bg = vi_mode_utils.get_mode_color(),
    }
  end,
  left_sep = function()
    return {
      str = " ",
      hl = { bg = vi_mode_utils.get_mode_color() },
    }
  end,
  right_sep = {
    "",
    function()
      return {
        str = " ",
        hl = { bg = vi_mode_utils.get_mode_color() },
      }
    end,
    function()
      return {
        str = "right_filled",
        hl = { bg = c.base02, fg = vi_mode_utils.get_mode_color() },
      }
    end,
  },
  icon = "",
})

table.insert(components.active[1], {
  provider = function()
    return vim.fn.getcwd():match("([^/]+)$") .. " "
  end,
  hl = { bg = c.base02, fg = c.base01 },
  left_sep = { str = " ", hl = { bg = c.base02 } },
  right_sep = {
    {
      str = "right_filled",
      hl = { bg = c.base05, fg = c.base02 },
    },
    " ",
  },
  truncate_hide = true,
})

local file_info = {
  provider = {
    name = "file_info",
    opts = {
      type = "relative",
      file_modified_icon = "",
    },
    hl = { bg = c.base02 },
    left_sep = { str = " ", hl = { bg = c.base02 } },
    right_sep = {
      str = "right_filled",
      hl = { bg = c.base05, fg = c.base02 },
    },
  },
  short_provider = {
    name = "file_info",
    opts = {
      type = "relative-short",
      file_modified_icon = "",
    },
    hl = { bg = c.base02 },
    left_sep = { str = " ", hl = { bg = c.base02 } },
    right_sep = {
      str = "right_filled",
      hl = { bg = c.base05, fg = c.base02 },
    },
  },
}

table.insert(components.active[1], file_info)

table.insert(components.active[1], {
  provider = "git_branch",
  left_sep = { str = " ", hl = { bg = c.base05 } },
})
table.insert(components.active[1], {
  provider = "git_diff_added",
  hl = { fg = c.rgreen },
  icon = " +",
})

table.insert(components.active[1], {
  provider = "git_diff_changed",
  hl = { fg = c.yellow },
  icon = " ~",
})

table.insert(components.active[1], {
  provider = "git_diff_removed",
  hl = { fg = c.red },
  icon = " -",
  right_sep = {
    { str = " ", always_visible = true },
    {
      str = "right_filled",
      hl = { bg = c.base02, fg = c.base05 },
      always_visible = true,
    },
  },
})

table.insert(components.active[1], {
  provider = "lsp_client_names",
  hl = { bg = c.base02, fg = c.base01 },
  left_sep = { str = " ", hl = { bg = c.base02 } },
  right_sep = { str = " ", hl = { bg = c.base02 } },
  truncate_hide = true,
})

table.insert(components.active[1], {
  provider = function()
    return require("lsp-progress").progress() .. " "
  end,
  hl = { bg = c.base02, fg = c.base01 },
  right_sep = {
    {
      str = "right_filled",
      hl = { bg = c.base05, fg = c.base02 },
    },
  },
  truncate_hide = true,
})

local severity = vim.diagnostic.severity

table.insert(components.active[1], {
  provider = "diagnostic_errors",
  enabled = function()
    return lsp.diagnostics_exist(severity.ERROR)
  end,
  hl = { bg = c.base05, fg = c.c_red },
  icon = " E ",
})

table.insert(components.active[1], {
  provider = "diagnostic_warnings",
  enabled = function()
    return lsp.diagnostics_exist(severity.WARN)
  end,
  hl = { bg = c.base05, fg = c.c_yellow },
  icon = " W ",
})

table.insert(components.active[1], {
  provider = "diagnostic_info",
  enabled = function()
    return lsp.diagnostics_exist(severity.INFO)
  end,
  hl = { bg = c.base05, fg = c.c_sky },
  icon = " I ",
})

table.insert(components.active[1], {
  provider = "diagnostic_hints",
  enabled = function()
    return lsp.diagnostics_exist(severity.HINT)
  end,
  hl = { bg = c.base05, fg = c.blue },
  icon = " H ",
})

table.insert(components.active[1], {
  provider = " ",
  hl = { bg = c.base05 },
  right_sep = {
    str = "right_filled",
    hl = { bg = c.base02, fg = c.base05 },
  },
})

local navic = require("nvim-navic")
table.insert(components.active[1], {
  provider = function()
    return navic.get_location() .. " "
  end,
  enabled = function()
    return navic.is_available()
  end,
  hl = { bg = c.base02, fg = "yellow" },
  left_sep = { str = " ", hl = { bg = c.base02 } },
  right_sep = {
    {
      str = "right_filled",
      hl = { bg = c.base05, fg = c.base02 },
    },
    " ",
  },
  truncate_hide = true,
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

table.insert(components.active[2], {
  provider = file_osinfo,
  hl = { bg = c.base02, fg = c.base01 },
  left_sep = {
    { str = "left_filled", hl = { bg = c.base05, fg = c.base02 } },
    { str = " ", hl = { bg = c.base02 } },
  },
  truncate_hide = true,
})

table.insert(components.active[2], {
  provider = "file_type",
  hl = { bg = c.base02, fg = c.base01 },
  left_sep = { str = " ", hl = { bg = c.base02 } },
  truncate_hide = true,
})

table.insert(components.active[2], {
  provider = "file_encoding",
  hl = { bg = c.base02, fg = c.base01 },
  left_sep = { str = " ", hl = { bg = c.base02, fg = c.base05 } },
  right_sep = { str = " ", hl = { bg = c.base02 } },
  truncate_hide = true,
})

table.insert(components.active[2], {
  provider = "file_size",
  enabled = function()
    return vim.fn.getfsize(vim.fn.expand("%:p")) > 0
  end,
  left_sep = {
    { str = "left_filled", hl = { bg = c.base02, fg = c.base05 } },
    " ",
  },
  right_sep = " ",
})

table.insert(components.active[2], {
  provider = "position",
  hl = function()
    return {
      name = vi_mode_utils.get_mode_highlight_name(),
      bg = vi_mode_utils.get_mode_color(),
    }
  end,
  left_sep = {
    function()
      return {
        str = "left_filled",
        hl = { bg = c.base05, fg = vi_mode_utils.get_mode_color() },
      }
    end,
    function()
      return {
        str = " ",
        hl = { bg = vi_mode_utils.get_mode_color() },
      }
    end,
  },
})

table.insert(components.inactive[1], {
  provider = "file_type",
  hl = { fg = "white", bg = "oceanblue", style = "bold" },
  left_sep = { str = " ", hl = { fg = "NONE", bg = "oceanblue" } },
  right_sep = {
    { str = " ", hl = { fg = "NONE", bg = "oceanblue" } },
    "right_filled",
  },
})

table.insert(components.inactive[1], file_info)

table.insert(components.inactive[1], {
  provider = "git_branch",
  left_sep = { str = " ", hl = { bg = c.base05 } },
})

local colours = {
  bg = c.base05,
  black = c.base05,
  yellow = c.yellow,
  cyan = c.cyan,
  oceanblue = c.dblue,
  green = c.green,
  orange = c.orange,
  violet = c.violet,
  magenta = c.magenta,
  white = c.base2,
  fg = c.base2,
  skyblue = c.blue,
  red = c.red,
}

local separators = {
  vertical_bar = "┃",
  vertical_bar_thin = "│",
  left = "",
  right = "",
  block = "█",
  left_filled = "",
  right_filled = "",
  slant_left = "",
  slant_left_thin = "",
  slant_right = "",
  slant_right_thin = "",
  slant_left_2 = "",
  slant_left_2_thin = "",
  slant_right_2 = "",
  slant_right_2_thin = "",
  left_rounded = "",
  left_rounded_thin = "",
  right_rounded = "",
  right_rounded_thin = "",
  circle = "●",
}

local vi_mode_colors = {
  NORMAL = c.dgreen,
  OP = c.dgreen,
  INSERT = "red",
  VISUAL = "skyblue",
  BLOCK = "skyblue",
  REPLACE = "violet",
  ["V-REPLACE"] = "violet",
  ENTER = "cyan",
  MORE = "cyan",
  SELECT = "orange",
  COMMAND = c.dgreen,
  SHELL = c.dgreen,
  TERM = c.dgreen,
  NONE = "yellow",
}

require("feline").setup({
  theme = colours,
  separators = separators,
  components = components,
  vi_mode_colors = vi_mode_colors,
})
