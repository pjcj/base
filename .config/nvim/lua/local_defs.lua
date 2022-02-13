local local_defs = {
  map = {
    defmap = { noremap = true, silent = true } -- default map options,
  },
  colour = {
    base03    = "#001920",
    base02    = "#022731",
    base01    = "#586e75",
    base00    = "#657b83",
    base0     = "#839496",
    base1     = "#93a1a1",
    base2     = "#eee8d5",
    base3     = "#fdf6e3",
    yellow    = "#b58900",
    orange    = "#cb4b16",
    red       = "#dc322f",
    magenta   = "#d33682",
    violet    = "#6c71c4",
    blue      = "#268bd2",
    cyan      = "#2aa198",
    green     = "#859900",
    normal    = "#9599dc",

    base04    = "#00090c", -- darker than base03
    base05    = "#0e3c49", -- lighter than base02
    base06    = "#012028", -- lighter than base03
    llyellow  = "#f0a63f", -- light yellow
    lyellow   = "#de860e", -- light yellow
    dyellow   = "#433200", -- dark yellow
    dorange   = "#7d2500", -- dark orange
    dred      = "#400200", -- dark red
    ddred     = "#2b0200", -- dark dark red
    dddred    = "#150100", -- dark dark dark red
    lviolet   = "#c0c3ef",
    dcyan     = "#04746c", -- dark cyan
    dblue     = "#06568f", -- dark blue
    rgreen    = "#25ad2e", -- a nice green for diffs (opposite of red)
    dgreen    = "#017008", -- dark green
    ddgreen   = "#003203", -- dark dark green

    none      = "none",
    reverse   = "reverse",
    underline = "underline",
  },
  fn = {
  },
}

local function set_colour(group, part, colour)
  vim.cmd(string.format("highlight %s %s=%s", group, part, colour))
end

local_defs.fn.set_buffer_colours = function()
  local c = local_defs.colour

  set_colour("Normal",                               "guifg", c.normal   )
  set_colour("SpecialKey",                           "guibg", c.base03   )
  set_colour("SpellBad",                             "guibg", c.base03   )
  set_colour("SpellBad",                             "guifg", c.dorange  )
  set_colour("SpellBad",                             "gui",   c.none     )
  set_colour("SpellCap",                             "guibg", c.blue     )
  set_colour("SpellCap",                             "guifg", c.base03   )
  set_colour("SpellCap",                             "gui",   c.none     )
  set_colour("SpellRare",                            "guibg", c.yellow   )
  set_colour("SpellRare",                            "guifg", c.base03   )
  set_colour("SpellRare",                            "gui",   c.none     )
  set_colour("SpellLocal",                           "guibg", c.green    )
  set_colour("SpellLocal",                           "guifg", c.base03   )
  set_colour("SpellLocal",                           "gui",   c.none     )
  set_colour("LineNr",                               "guibg", c.base03   )
  set_colour("SignColumn",                           "guibg", c.base03   )
  set_colour("ColorColumn",                          "guibg", c.base06   )
  set_colour("CursorLine",                           "guibg", c.base02   )
  set_colour("CursorColumn",                         "guibg", c.base02   )
  set_colour("CursorLineNr",                         "guibg", c.base03   )
  set_colour("DiffAdd",                              "guibg", c.base03   )
  set_colour("DiffAdd",                              "guifg", c.rgreen   )
  set_colour("DiffChange",                           "guibg", c.base03   )
  set_colour("DiffDelete",                           "guibg", c.base03   )
  set_colour("DiffAdded",                            "guifg", c.rgreen   )
  set_colour("Search",                               "guibg", c.violet   )
  set_colour("Search",                               "guifg", c.base03   )
  set_colour("Search",                               "gui",   c.none     )
  set_colour("TabLineSel",                           "guibg", c.base03   )
  set_colour("TabLineSel",                           "guifg", c.violet   )
  set_colour("Folded",                               "gui",   c.none     )
  set_colour("MatchParen",                           "guibg", c.base00   )
  set_colour("MatchParen",                           "guifg", c.none     )
  set_colour("MatchParenCur",                        "guibg", c.base02   )
  set_colour("MatchParenCur",                        "guifg", c.none     )
  set_colour("NormalFloat",                          "guibg", c.base04   )
  set_colour("FloatBorder",                          "guibg", c.base04   )
  set_colour("FloatBorder",                          "guifg", c.normal   )
  set_colour("Pmenu",                                "guifg", c.dddred   )
  set_colour("Pmenu",                                "guibg", c.base2    )
  set_colour("PmenuSel",                             "guifg", c.dorange  )
  set_colour("PmenuSel",                             "guibg", c.base2    )
  set_colour("Visual",                               "guifg", c.base1    )
  set_colour("Visual",                               "guibg", c.dred     )
  set_colour("Visual",                               "gui",   c.none     )

  set_colour("Cursor",                               "guibg", c.llyellow )

  set_colour("GitSignsAdd",                          "guibg", c.base03   )
  set_colour("GitSignsAdd",                          "guifg", c.rgreen   )
  set_colour("GitSignsChange",                       "guibg", c.base03   )
  set_colour("GitSignsChange",                       "guifg", c.yellow   )
  set_colour("GitSignsDelete",                       "guibg", c.base03   )
  set_colour("GitSignsDelete",                       "guifg", c.red      )
  set_colour("GitSignsCurrentLineBlame",             "guifg", c.base05   )
  set_colour("GitSignsAddLnInline",                  "guibg", c.ddgreen  )
  set_colour("GitSignsChangeLnInline",               "guibg", c.dyellow  )
  set_colour("GitSignsDeleteLnInline",               "guibg", c.dred     )

  set_colour("IndentOdd",                            "guifg", c.yellow   )
  set_colour("IndentOdd",                            "guibg", c.none     )
  set_colour("IndentEven",                           "guifg", c.yellow   )
  set_colour("IndentEven",                           "guibg", c.base02   )

  set_colour("IndentBlanklineContextStart",          "guibg", c.ddred    )
  set_colour("IndentBlanklineContextStart",          "gui"  , c.underline)

  set_colour("GoDiagnosticError",                    "guibg", c.none     )
  set_colour("GoDiagnosticError",                    "guifg", c.red      )

  set_colour("LspDiagnosticsDefaultError",           "guifg", c.red      )
  set_colour("LspDiagnosticsVirtualTextError",       "guifg", c.dorange  )
  set_colour("LspDiagnosticsVirtualTextWarning",     "guifg", c.dyellow  )
  set_colour("LspDiagnosticsVirtualTextInformation", "guifg", c.dcyan    )
  set_colour("LspDiagnosticsVirtualTextHint",        "guifg", c.dblue    )
  set_colour("LspDiagnosticsSignError",              "guifg", c.orange   )
  set_colour("LspDiagnosticsSignWarning",            "guifg", c.yellow   )
  set_colour("LspDiagnosticsSignInformation",        "guifg", c.cyan     )
  set_colour("LspDiagnosticsSignHint",               "guifg", c.blue     )

  set_colour("TSDefinition",                         "guibg", c.yellow   )
  set_colour("TSDefinition",                         "guifg", c.base02   )
  set_colour("TSDefinitionUsage",                    "guibg", c.base05   )

  set_colour("ALEVirtualTextError",                  "guifg", c.dorange  )
  set_colour("ALEVirtualTextWarning",                "guifg", c.dyellow  )
  set_colour("ALEVirtualTextInfo",                   "guifg", c.dcyan    )
  set_colour("AleErrorSign",                         "guifg", c.orange   )
  set_colour("AleWarningSign",                       "guifg", c.yellow   )
  set_colour("AleInfoSign",                          "guifg", c.cyan     )

  set_colour("ScrollView",                           "guibg", c.blue     )

  set_colour("CmpItemAbbr",                          "guibg", c.normal   )
  set_colour("CmpItemAbbrDeprecated",                "guibg", c.red      )
  set_colour("CmpItemAbbrMatch",                     "guibg", c.base2    )
  set_colour("CmpItemAbbrMatchFuzzy",                "guibg", c.base1    )
  set_colour("CmpItemKind",                          "guibg", c.yellow   )
  set_colour("CmpItemMenu",                          "guibg", c.base0    )
end

local alternate_indent = function()
  local b  = vim.b                             -- a table to access buffer variables
  local hl = { "IndentOdd", "IndentEven" }
  b.indent_blankline_char_highlight_list                 = hl
  b.indent_blankline_space_char_highlight_list           = hl
  b.indent_blankline_space_char_blankline_highlight_list = hl
  b.indent_blankline_context_highlight_list              = hl
end

local_defs.fn.set_buffer_settings = function()
  local ft   = vim.bo.filetype
  local b    = vim.b                             -- a table to access buffer variables
  local lopt = vim.opt_local                     -- set local options
  local vmap = vim.api.nvim_set_keymap           -- global mappings
  local bmap = vim.api.nvim_buf_set_keymap       -- local mappings
  local l    = local_defs

  if ft == "go" or ft == "gomod" or ft == "make" then
    lopt.listchars = { tab = "  ", trail = "·" }

    local e = b.editorconfig
    -- print("editorconfig", e.indent_style, e.indent_size)
    if e.indent_style == nil then
      lopt.expandtab  = false
      -- print("unset expandtab")
    end
    if e.indent_size == nil then
      lopt.tabstop    = 2
      lopt.shiftwidth = 2
      -- print("set tabstop shiftwidth 2")
    end

    alternate_indent()

    if ft == "go" then
      bmap(0, "n", "<leader>oa", "<cmd>GoAlternate<cr>",     l.map.defmap)
      bmap(0, "n", "<leader>oi", "<cmd>GoImports<cr>",       l.map.defmap)
      bmap(0, "n", "<leader>os", "<cmd>GoSameIdsToggle<cr>", l.map.defmap)
    end
    return
  end

  lopt.listchars = { tab = "» ", trail = "·" }
  lopt.tabstop   = 8
  if vim.bo.shiftwidth < 3 then
    alternate_indent()
  else
    b.indent_blankline_char_highlight_list                 = { "IndentEven"  }
    b.indent_blankline_space_char_highlight_list           = { "IndentSpace" }
    b.indent_blankline_space_char_blankline_highlight_list = {               }
    b.indent_blankline_context_highlight_list              = { "IndentEven"  }
  end

  if ft == "gitcommit" then
    lopt.colorcolumn = { 50, 72 }
    lopt.textwidth   = 72
    lopt.spell       = true
    lopt.spelllang   = "en_gb"
  end

  if ft == "perl" then
    vmap("n", "<F4>", [[:execute "tjump /^\\(_build_\\)\\?" . expand("<cword>") . "$"<cr>]], l.map.defmap)
    vmap("i", "<F2>", "sub ($self) {<CR>}<ESC>kea<Space>", l.map.defmap)
    vmap("i", "<F3>", "$self->{}<ESC>i",                   l.map.defmap)
    vmap("i", "<F4>", "$self->",                           l.map.defmap)
    vim.cmd([[iabbr ,, =>]])
    vim.cmd([[TSBufDisable highlight]])
  end
end

return local_defs
