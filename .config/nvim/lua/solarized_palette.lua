-- Solarized-derived colour palette, shared as the single source of truth.
--
-- This module has no dependencies (no vim, no plugins), so it can be required
-- both from Neovim (via local_defs) and from other Lua runtimes such as
-- Hammerspoon (see .config/hammerspoon/which_key.lua).

-- stylua: ignore start
return {
  base03      = "#001920",
  base02      = "#022731",
  base01      = "#586e75",
  base00      = "#657b83",
  base0       = "#839496",
  base1       = "#93a1a1",
  base2       = "#eee8d5",
  base3       = "#fdf6e3",
  yellow      = "#b58900",
  orange      = "#cb4b16",
  red         = "#dc322f",
  magenta     = "#d33682",
  violet      = "#6c71c4",
  blue        = "#268bd2",
  cyan        = "#2aa198",
  green       = "#859900",
  normal      = "#9599dc",

  base04      = "#00090c", -- darker than base03
  base05      = "#0e3c49", -- lighter than base02
  base06      = "#012028", -- lighter than base03
  base07      = "#052c37", -- between base02 and base05
  peach       = "#ffdc79", -- peach
  pyellow     = "#fff179", -- pale yellow
  llyellow    = "#f0a63f", -- light yellow
  lyellow     = "#de860e", -- light yellow
  dyellow     = "#433200", -- dark yellow
  dorange     = "#7d2500", -- dark orange
  llllred     = "#ffcdcc", -- light light light light red
  lllred      = "#ffacaa", -- light light light red
  llred       = "#ff8784", -- light light red
  lred        = "#f05a5c", -- light red
  mred        = "#64110f", -- medium red
  lmred       = "#d37b79", -- light medium red
  dred        = "#400200", -- dark red
  ddred       = "#2b0200", -- dark dark red
  dddred      = "#150100", -- dark dark dark red
  lviolet     = "#c0c3ef", -- light violet
  mviolet     = "#7c81e4", -- medium violet
  dviolet     = "#323799", -- dark violet
  ddviolet    = "#0F1363", -- dark dark violet
  dcyan       = "#04746c", -- dark cyan
  llblue      = "#9fcff2", -- light light blue
  lblue       = "#73b5e4", -- light blue
  dblue       = "#06568f", -- dark blue
  ddblue      = "#023458", -- dark dark blue
  lllgreen    = "#c9f5cc", -- light light light green
  llgreen     = "#98e59d", -- light light green
  lgreen      = "#6dd374", -- light green
  rgreen      = "#25ad2e", -- a nice green for diffs (opposite of red)
  dgreen      = "#017008", -- dark green
  ddgreen     = "#003203", -- dark dark green

  c_rosewater = "#ffacaa",
  c_flamingo  = "#ff8784",
  c_pink      = "#ffc67b",
  c_mauve     = "#6c71c4",
  c_red       = "#fe9569",
  c_maroon    = "#9599dc",
  c_peach     = "#ffdc79",
  c_yellow    = "#fff179",
  c_green     = "#6dd374",
  c_teal      = "#a9eae5",
  c_sky       = "#78d3cc",
  c_sapphire  = "#9fcff2",
  c_blue      = "#73b5e4",
  c_lavender  = "#c0c3ef",
  c_text      = "#fdf6e3",
  c_subtext1  = "#eee8d5",
  c_subtext0  = "#93a1a1",
  c_overlay2  = "#839496",
  c_overlay1  = "#657b83",
  c_overlay0  = "#586e75",
  c_surface2  = "#0e3c49",
  c_surface1  = "#022731",
  c_surface0  = "#012028",
  c_base      = "#001920",
  c_mantle    = "#00090c",
  c_crust     = "#000000",

  none = "none",
  reverse = "reverse",
  underline = "underline",
}
-- stylua: ignore end
