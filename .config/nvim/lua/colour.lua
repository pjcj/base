local cmd  = vim.cmd        -- run Vim commands
local fn   = vim.fn         -- call Vim functions
local g    = vim.g          -- a table to access global variables
local opt  = vim.opt        -- set options
local api  = vim.api        -- vim api
local exec = api.nvim_exec  -- execute nvim

opt.termguicolors = true
opt.background    = "dark"
cmd "colorscheme solarized"
cmd "highlight Comment guibg=Red"

local base03  = "#001920"
local base02  = "#022731"
local base01  = "#586e75"
local base00  = "#657b83"
local base0   = "#839496"
local base1   = "#93a1a1"
local base2   = "#eee8d5"
local base3   = "#fdf6e3"
local yellow  = "#b58900"
local orange  = "#cb4b16"
local red     = "#dc322f"
local magenta = "#d33682"
local violet  = "#6c71c4"
local blue    = "#268bd2"
local cyan    = "#2aa198"
local green   = "#859900"
local normal  = "#9599dc"

local rgreen  = "#25ad2e"  -- a nice green for diffs (opposite of red)
local base04  = "#00090C"  -- darker than base03
local base05  = "#0E3C49"  -- lighter than base02

function set_colour(group, part, colour)
  cmd(string.format("highlight %s %s=%s", group, part, colour))
end

function _G.set_buffer_colours()
  set_colour("Normal",        "guifg", normal)
  set_colour("SpecialKey",    "guibg", base03)
  set_colour("SpellBad",      "guibg", violet)
  set_colour("SpellBad",      "guifg", base03)
  set_colour("SpellBad",      "gui",   "NONE")
  set_colour("SpellCap",      "guibg", blue  )
  set_colour("SpellCap",      "guifg", base03)
  set_colour("SpellCap",      "gui",   "NONE")
  set_colour("SpellRare",     "guibg", yellow)
  set_colour("SpellRare",     "guifg", base03)
  set_colour("SpellRare",     "gui",   "NONE")
  set_colour("SpellLocal",    "guibg", green )
  set_colour("SpellLocal",    "guifg", base03)
  set_colour("SpellLocal",    "gui",   "NONE")
  set_colour("LineNr",        "guibg", base03)
  set_colour("CursorLine",    "guibg", base02)
  set_colour("CursorColumn",  "guibg", base02)
  set_colour("CursorLineNr",  "guibg", base03)
  set_colour("DiffAdd",       "guibg", base03)
  set_colour("DiffAdd",       "guifg", rgreen)
  set_colour("DiffChange",    "guibg", base03)
  set_colour("DiffDelete",    "guibg", base03)
  set_colour("diffAdded",     "guifg", rgreen)
  set_colour("Search",        "guibg", violet)
  set_colour("Search",        "guifg", base03)
  set_colour("Search",        "gui",   "NONE")
  set_colour("TabLineSel",    "guibg", base03)
  set_colour("TabLineSel",    "guifg", violet)
  set_colour("Folded",        "gui",   "NONE")
  set_colour("MatchParen",    "guibg", base00)
  set_colour("MatchParen",    "guifg", "NONE")
  set_colour("MatchParenCur", "guibg", base02)
  set_colour("MatchParenCur", "guifg", "NONE")
  set_colour("NormalFloat",   "guibg", base04)
end
