local wezterm = require "wezterm"
local mux = wezterm.mux
local act = wezterm.action

local hostname = wezterm.hostname()

local c = {}

c.term = "wezterm"

if hostname == "T52U" then
  c.front_end = "WebGpu"
  c.webgpu_power_preference = "HighPerformance"

  c.font = wezterm.font("Inconsolata NF")
  c.font_size = 15
  c.command_palette_font_size = 24
  c.initial_cols = 354
  c.initial_rows = 96
elseif hostname == "mbp.localdomain" then
  c.font = wezterm.font("Inconsolata")
  c.font_size = 15
  c.command_palette_font_size = 24
  c.initial_cols = 222
  c.initial_rows = 57
else
  c.font_size = 12
  c.command_palette_font_size = 20
  c.initial_cols = 120
  c.initial_rows = 40
end

c.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.5,
}

c.adjust_window_size_when_changing_font_size = false

-- c.color_scheme = "Solarized Dark - Patched"
c.colors = {
  background = "#001920",
  foreground = "#fff9c7",
  cursor_bg = "#dc322f",
  cursor_fg = "#001920",
  cursor_border = "#586e75",
  compose_cursor = "#6dd374",
  selection_bg = "#f0a63f",
  selection_fg = "#001920",
  ansi = {
    "#022731",  -- black
    "#dc322f",  -- red
    "#25ad2e",  -- green
    "#b58900",  -- yellow
    "#268bd2",  -- blue
    "#d33682",  -- magenta
    "#2aa198",  -- cyan
    "#eee8d5",  -- white
  },
  brights = {
    "#001920",  -- bright black
    "#cb4b16",  -- bright red
    "#586e75",  -- bright green
    "#657b83",  -- bright yellow
    "#839496",  -- bright blue
    "#6c71c4",  -- bright magenta
    "#93a1a1",  -- bright cyan
    "#fdf6e3",  -- bright white
  },
  indexed = {
    [151] = "#ced4d4",
    [152] = "#00090c", -- darker than base03
    [153] = "#0e3c49", -- lighter than base02
    [154] = "#012028", -- lighter than base03
    [155] = "#ffdc79", -- peach
    [156] = "#fff179", -- pale yellow
    [157] = "#f0a63f", -- light yellow
    [158] = "#de860e", -- light yellow
    [159] = "#433200", -- dark yellow
    [160] = "#7d2500", -- dark orange
    [161] = "#ffacaa", -- light light light red
    [162] = "#ff8784", -- light light red
    [163] = "#f05a5c", -- light red
    [164] = "#64110f", -- medium red
    [165] = "#d37b79", -- light medium red
    [166] = "#400200", -- dark red
    [167] = "#2b0200", -- dark dark red
    [168] = "#150100", -- dark dark dark red
    [169] = "#c0c3ef", -- light violet
    [170] = "#7c81e4", -- medium violet
    [171] = "#323799", -- dark violet
    [172] = "#0F1363", -- dark dark violet
    [173] = "#04746c", -- dark cyan
    [174] = "#9fcff2", -- light light blue
    [175] = "#73b5e4", -- light blue
    [176] = "#06568f", -- dark blue
    [177] = "#023458", -- dark dark blue
    [178] = "#6dd374", -- light green
    [179] = "#25ad2e", -- a nice green for diffs (opposite of red)
    [180] = "#017008", -- dark green
    [181] = "#003203", -- dark dark green
  },
}

c.disable_default_key_bindings = true

c.leader = { key = ".", mods = "CTRL", timeout_milliseconds = 3000 }

c.keys = {
  { key = "s", mods = "LEADER|CTRL", action = wezterm.action.SendKey { key = "s", mods = "CTRL" } },

  { key = "+", mods = "CTRL", action = "IncreaseFontSize" },
  { key = "-", mods = "CTRL", action = "DecreaseFontSize" },
  { key = '*', mods = 'CTRL', action = act.ResetFontSize },
  { key = "Enter", mods = "CTRL|SHIFT", action = wezterm.action.TogglePaneZoomState },
  { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "c", mods = "ALT", action = act.CopyTo "Clipboard" },
  { key = "v", mods = "ALT", action = act.PasteFrom "Clipboard" },
  { key = "d", mods = "LEADER", action = act.ShowDebugOverlay },
  { key = "r", mods = "LEADER", action = act.ReloadConfiguration },
  { key = 'l', mods = 'LEADER', action = act.ShowLauncher },
  { key = 'p', mods = 'LEADER', action = act.ActivateCommandPalette },


  -- { key = '0', mods = 'CTRL', action = act.ActivateTab(0) },
  -- { key = '!', mods = 'SHIFT|CTRL', action = act.ActivateTab(0) },
  -- { key = '"', mods = 'ALT|CTRL', action = act.SplitVertical{ domain =  'CurrentPaneDomain' } },
  -- { key = '"', mods = 'SHIFT|ALT|CTRL', action = act.SplitVertical{ domain =  'CurrentPaneDomain' } },
  -- { key = '#', mods = 'CTRL', action = act.ActivateTab(2) },
  -- { key = '#', mods = 'SHIFT|CTRL', action = act.ActivateTab(2) },
  -- { key = '$', mods = 'CTRL', action = act.ActivateTab(3) },
  -- { key = '$', mods = 'SHIFT|CTRL', action = act.ActivateTab(3) },
  -- { key = '%', mods = 'CTRL', action = act.ActivateTab(4) },
  -- { key = '%', mods = 'SHIFT|CTRL', action = act.ActivateTab(4) },
  -- { key = '%', mods = 'ALT|CTRL', action = act.SplitHorizontal{ domain =  'CurrentPaneDomain' } },
  -- { key = '%', mods = 'SHIFT|ALT|CTRL', action = act.SplitHorizontal{ domain =  'CurrentPaneDomain' } },
  -- { key = '&', mods = 'CTRL', action = act.ActivateTab(6) },
  -- { key = '&', mods = 'SHIFT|CTRL', action = act.ActivateTab(6) },
  -- { key = '\'', mods = 'SHIFT|ALT|CTRL', action = act.SplitVertical{ domain =  'CurrentPaneDomain' } },
  -- { key = '(', mods = 'CTRL', action = act.ActivateTab(-1) },
  -- { key = '(', mods = 'SHIFT|CTRL', action = act.ActivateTab(-1) },
  -- { key = ')', mods = 'CTRL', action = act.ResetFontSize },
  -- { key = ')', mods = 'SHIFT|CTRL', action = act.ResetFontSize },
  -- { key = '*', mods = 'CTRL', action = act.ActivateTab(7) },
  -- { key = '*', mods = 'SHIFT|CTRL', action = act.ActivateTab(7) },
  -- { key = '+', mods = 'CTRL', action = act.IncreaseFontSize },
  -- { key = '+', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
  -- { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  -- { key = '-', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },
  -- { key = '-', mods = 'SUPER', action = act.DecreaseFontSize },
  -- { key = '0', mods = 'CTRL', action = act.ResetFontSize },
  -- { key = '0', mods = 'SHIFT|CTRL', action = act.ResetFontSize },
  -- { key = '0', mods = 'SUPER', action = act.ResetFontSize },
  -- { key = '1', mods = 'SHIFT|CTRL', action = act.ActivateTab(0) },
  -- { key = '1', mods = 'SUPER', action = act.ActivateTab(0) },
  -- { key = '2', mods = 'SHIFT|CTRL', action = act.ActivateTab(1) },
  -- { key = '2', mods = 'SUPER', action = act.ActivateTab(1) },
  -- { key = '3', mods = 'SHIFT|CTRL', action = act.ActivateTab(2) },
  -- { key = '3', mods = 'SUPER', action = act.ActivateTab(2) },
  -- { key = '4', mods = 'SHIFT|CTRL', action = act.ActivateTab(3) },
  -- { key = '4', mods = 'SUPER', action = act.ActivateTab(3) },
  -- { key = '5', mods = 'SHIFT|CTRL', action = act.ActivateTab(4) },
  -- { key = '5', mods = 'SHIFT|ALT|CTRL', action = act.SplitHorizontal{ domain =  'CurrentPaneDomain' } },
  -- { key = '5', mods = 'SUPER', action = act.ActivateTab(4) },
  -- { key = '6', mods = 'SHIFT|CTRL', action = act.ActivateTab(5) },
  -- { key = '6', mods = 'SUPER', action = act.ActivateTab(5) },
  -- { key = '7', mods = 'SHIFT|CTRL', action = act.ActivateTab(6) },
  -- { key = '7', mods = 'SUPER', action = act.ActivateTab(6) },
  -- { key = '8', mods = 'SHIFT|CTRL', action = act.ActivateTab(7) },
  -- { key = '8', mods = 'SUPER', action = act.ActivateTab(7) },
  -- { key = '9', mods = 'SHIFT|CTRL', action = act.ActivateTab(-1) },
  -- { key = '9', mods = 'SUPER', action = act.ActivateTab(-1) },
  -- { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  -- { key = '=', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
  -- { key = '=', mods = 'SUPER', action = act.IncreaseFontSize },
  -- { key = '@', mods = 'CTRL', action = act.ActivateTab(1) },
  -- { key = '@', mods = 'SHIFT|CTRL', action = act.ActivateTab(1) },
  -- { key = 'C', mods = 'CTRL', action = act.CopyTo 'Clipboard' },
  -- { key = 'C', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
  -- { key = 'F', mods = 'CTRL', action = act.Search 'CurrentSelectionOrEmptyString' },
  -- { key = 'F', mods = 'SHIFT|CTRL', action = act.Search 'CurrentSelectionOrEmptyString' },
  -- { key = 'K', mods = 'CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
  -- { key = 'K', mods = 'SHIFT|CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
  -- { key = 'L', mods = 'CTRL', action = act.ShowDebugOverlay },
  -- { key = 'L', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
  -- { key = 'M', mods = 'CTRL', action = act.Hide },
  -- { key = 'M', mods = 'SHIFT|CTRL', action = act.Hide },
  -- { key = 'N', mods = 'CTRL', action = act.SpawnWindow },
  -- { key = 'N', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
  -- { key = 'P', mods = 'CTRL', action = act.ActivateCommandPalette },
  -- { key = 'P', mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
  -- { key = 'R', mods = 'CTRL', action = act.ReloadConfiguration },
  -- { key = 'R', mods = 'SHIFT|CTRL', action = act.ReloadConfiguration },
  -- { key = 'T', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
  -- { key = 'T', mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
  -- { key = 'U', mods = 'CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
  -- { key = 'U', mods = 'SHIFT|CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
  -- { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
  -- { key = 'V', mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
  -- { key = 'W', mods = 'CTRL', action = act.CloseCurrentTab{ confirm = true } },
  -- { key = 'W', mods = 'SHIFT|CTRL', action = act.CloseCurrentTab{ confirm = true } },
  -- { key = 'X', mods = 'CTRL', action = act.ActivateCopyMode },
  -- { key = 'X', mods = 'SHIFT|CTRL', action = act.ActivateCopyMode },
  -- { key = 'Z', mods = 'CTRL', action = act.TogglePaneZoomState },
  -- { key = '[', mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(-1) },
  -- { key = ']', mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(1) },
  -- { key = '^', mods = 'CTRL', action = act.ActivateTab(5) },
  -- { key = '^', mods = 'SHIFT|CTRL', action = act.ActivateTab(5) },
  -- { key = '_', mods = 'CTRL', action = act.DecreaseFontSize },
  -- { key = '_', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },
  -- { key = 'c', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
  -- { key = 'c', mods = 'SUPER', action = act.CopyTo 'Clipboard' },
  -- { key = 'f', mods = 'SHIFT|CTRL', action = act.Search 'CurrentSelectionOrEmptyString' },
  -- { key = 'f', mods = 'SUPER', action = act.Search 'CurrentSelectionOrEmptyString' },
  -- { key = 'k', mods = 'SHIFT|CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
  -- { key = 'k', mods = 'SUPER', action = act.ClearScrollback 'ScrollbackOnly' },
  -- { key = 'l', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
  -- { key = 'm', mods = 'SHIFT|CTRL', action = act.Hide },
  -- { key = 'm', mods = 'SUPER', action = act.Hide },
  -- { key = 'n', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
  -- { key = 'n', mods = 'SUPER', action = act.SpawnWindow },
  -- { key = 'p', mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
  -- { key = 'r', mods = 'SHIFT|CTRL', action = act.ReloadConfiguration },
  -- { key = 'r', mods = 'SUPER', action = act.ReloadConfiguration },
  -- { key = 't', mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
  -- { key = 't', mods = 'SUPER', action = act.SpawnTab 'CurrentPaneDomain' },
  -- { key = 'u', mods = 'SHIFT|CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
  -- { key = 'v', mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
  -- { key = 'v', mods = 'SUPER', action = act.PasteFrom 'Clipboard' },
  -- { key = 'w', mods = 'SHIFT|CTRL', action = act.CloseCurrentTab{ confirm = true } },
  -- { key = 'w', mods = 'SUPER', action = act.CloseCurrentTab{ confirm = true } },
  -- { key = 'x', mods = 'SHIFT|CTRL', action = act.ActivateCopyMode },
  -- { key = '{', mods = 'SUPER', action = act.ActivateTabRelative(-1) },
  -- { key = '{', mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(-1) },
  -- { key = '}', mods = 'SUPER', action = act.ActivateTabRelative(1) },
  -- { key = '}', mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(1) },
  -- { key = 'phys:Space', mods = 'SHIFT|CTRL', action = act.QuickSelect },
  -- { key = 'PageUp', mods = 'SHIFT', action = act.ScrollByPage(-1) },
  -- { key = 'PageUp', mods = 'CTRL', action = act.ActivateTabRelative(-1) },
  -- { key = 'PageUp', mods = 'SHIFT|CTRL', action = act.MoveTabRelative(-1) },
  -- { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(1) },
  -- { key = 'PageDown', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  -- { key = 'PageDown', mods = 'SHIFT|CTRL', action = act.MoveTabRelative(1) },
  -- { key = 'LeftArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Left' },
  -- { key = 'LeftArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Left', 1 } },
  -- { key = 'RightArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Right' },
  -- { key = 'RightArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Right', 1 } },
  -- { key = 'UpArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Up' },
  -- { key = 'UpArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Up', 1 } },
  -- { key = 'DownArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Down' },
  -- { key = 'DownArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Down', 1 } },
  -- { key = 'Insert', mods = 'SHIFT', action = act.PasteFrom 'PrimarySelection' },
  -- { key = 'Insert', mods = 'CTRL', action = act.CopyTo 'PrimarySelection' },
  -- { key = 'Copy', mods = 'NONE', action = act.CopyTo 'Clipboard' },
  -- { key = 'Paste', mods = 'NONE', action = act.PasteFrom 'Clipboard' },
}

-- c.key_tables = {
--   copy_mode = {
--     { key = 'Tab', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
--     { key = 'Tab', mods = 'SHIFT', action = act.CopyMode 'MoveBackwardWord' },
--     { key = 'Enter', mods = 'NONE', action = act.CopyMode 'MoveToStartOfNextLine' },
--     { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
--     { key = 'Space', mods = 'NONE', action = act.CopyMode{ SetSelectionMode =  'Cell' } },
--     { key = '$', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
--     { key = '$', mods = 'SHIFT', action = act.CopyMode 'MoveToEndOfLineContent' },
--     { key = ',', mods = 'NONE', action = act.CopyMode 'JumpReverse' },
--     { key = '0', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
--     { key = ';', mods = 'NONE', action = act.CopyMode 'JumpAgain' },
--     { key = 'F', mods = 'NONE', action = act.CopyMode{ JumpBackward = { prev_char = false } } },
--     { key = 'F', mods = 'SHIFT', action = act.CopyMode{ JumpBackward = { prev_char = false } } },
--     { key = 'G', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackBottom' },
--     { key = 'G', mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
--     { key = 'H', mods = 'NONE', action = act.CopyMode 'MoveToViewportTop' },
--     { key = 'H', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportTop' },
--     { key = 'L', mods = 'NONE', action = act.CopyMode 'MoveToViewportBottom' },
--     { key = 'L', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportBottom' },
--     { key = 'M', mods = 'NONE', action = act.CopyMode 'MoveToViewportMiddle' },
--     { key = 'M', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportMiddle' },
--     { key = 'O', mods = 'NONE', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
--     { key = 'O', mods = 'SHIFT', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
--     { key = 'T', mods = 'NONE', action = act.CopyMode{ JumpBackward = { prev_char = true } } },
--     { key = 'T', mods = 'SHIFT', action = act.CopyMode{ JumpBackward = { prev_char = true } } },
--     { key = 'V', mods = 'NONE', action = act.CopyMode{ SetSelectionMode =  'Line' } },
--     { key = 'V', mods = 'SHIFT', action = act.CopyMode{ SetSelectionMode =  'Line' } },
--     { key = '^', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLineContent' },
--     { key = '^', mods = 'SHIFT', action = act.CopyMode 'MoveToStartOfLineContent' },
--     { key = 'b', mods = 'NONE', action = act.CopyMode 'MoveBackwardWord' },
--     { key = 'b', mods = 'ALT', action = act.CopyMode 'MoveBackwardWord' },
--     { key = 'b', mods = 'CTRL', action = act.CopyMode 'PageUp' },
--     { key = 'c', mods = 'CTRL', action = act.CopyMode 'Close' },
--     { key = 'd', mods = 'CTRL', action = act.CopyMode{ MoveByPage = (0.5) } },
--     { key = 'e', mods = 'NONE', action = act.CopyMode 'MoveForwardWordEnd' },
--     { key = 'f', mods = 'NONE', action = act.CopyMode{ JumpForward = { prev_char = false } } },
--     { key = 'f', mods = 'ALT', action = act.CopyMode 'MoveForwardWord' },
--     { key = 'f', mods = 'CTRL', action = act.CopyMode 'PageDown' },
--     { key = 'g', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackTop' },
--     { key = 'g', mods = 'CTRL', action = act.CopyMode 'Close' },
--     { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
--     { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
--     { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
--     { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
--     { key = 'm', mods = 'ALT', action = act.CopyMode 'MoveToStartOfLineContent' },
--     { key = 'o', mods = 'NONE', action = act.CopyMode 'MoveToSelectionOtherEnd' },
--     { key = 'q', mods = 'NONE', action = act.CopyMode 'Close' },
--     { key = 't', mods = 'NONE', action = act.CopyMode{ JumpForward = { prev_char = true } } },
--     { key = 'u', mods = 'CTRL', action = act.CopyMode{ MoveByPage = (-0.5) } },
--     { key = 'v', mods = 'NONE', action = act.CopyMode{ SetSelectionMode =  'Cell' } },
--     { key = 'v', mods = 'CTRL', action = act.CopyMode{ SetSelectionMode =  'Block' } },
--     { key = 'w', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
--     { key = 'y', mods = 'NONE', action = act.Multiple{ { CopyTo =  'ClipboardAndPrimarySelection' }, { CopyMode =  'Close' } } },
--     { key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PageUp' },
--     { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'PageDown' },
--     { key = 'End', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
--     { key = 'Home', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
--     { key = 'LeftArrow', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
--     { key = 'LeftArrow', mods = 'ALT', action = act.CopyMode 'MoveBackwardWord' },
--     { key = 'RightArrow', mods = 'NONE', action = act.CopyMode 'MoveRight' },
--     { key = 'RightArrow', mods = 'ALT', action = act.CopyMode 'MoveForwardWord' },
--     { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'MoveUp' },
--     { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'MoveDown' },
--   },

--   search_mode = {
--     { key = 'Enter', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
--     { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
--     { key = 'n', mods = 'CTRL', action = act.CopyMode 'NextMatch' },
--     { key = 'p', mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
--     { key = 'r', mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
--     { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
--     { key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
--     { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
--     { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
--     { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
--   },
-- }

c.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom("PrimarySelection"),
  },
}

c.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- c.window_frame = {
 -- font = wezterm.font { family = "Noto Sans", weight = "Regular" },
-- }

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

wezterm.on(
  'format-tab-title',
  -- function(tab, tabs, panes, config, hover, max_width)
  function(tab, _, _, _, hover, max_width)
    local edge_background = '#0b0022'
    local background = '#1b1032'
    local foreground = '#808080'

    if tab.is_active then
      background = '#2b2042'
      foreground = '#c0c0c0'
    elseif hover then
      background = '#3b3052'
      foreground = '#909090'
    end

    local edge_foreground = background

    local title = tab_title(tab)

    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    title = wezterm.truncate_right(title, max_width - 2)

    return {
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_LEFT_ARROW },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = title },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_RIGHT_ARROW },
    }
  end
)

c.pane_focus_follows_mouse = true

c.window_close_confirmation = "NeverPrompt"

if hostname == "T52U" then
  c.ssh_domains = {
    {
      name = "pyx",
      remote_address = "10.20.30.3",
      username = "pjcj",
      ssh_option = {
        IdentityFile = "/mnt/c/Users/pjcj/.ssh/id_ed25519",
      }
    },
  }
  c.default_domain = "WSL:Ubuntu"
  c.unix_domains = {
    {
      name = "unix",
    }
  }
end

wezterm.on("gui-startup", function()
  local window, tab, pane1, pane2, pane3
  tab, pane1, window = mux.spawn_window({})

  if hostname == "T52U" then
    tab:set_title("wsl")
    pane2 = pane1:split { direction = "Left", size = 0.4 }
    pane3 = pane2:split { direction = "Bottom", size = 0.5 }
    pane1:send_text 'tm sh\n'
    pane2:send_text([[ ssh -t pjcj 'zsh -i -c "tm main"' ]] .. "\n")
    pane3:send_text([[ ssh -t cp1 'zsh -i -c "tm cp1"' ]] .. "\n")

    tab, pane1, window = window:spawn_tab {}
    tab:set_title("pyx")
    pane2 = pane1:split { direction = "Left", size = 0.25 }
    pane1:send_text([[ ssh -t pyx-22 'zsh -i -c "tm base"' ]] .. "\n")
    pane2:send_text 'ssh pyx-22\n'

    tab, pane1, window = window:spawn_tab {}
    tab:set_title("ca")
    pane2 = pane1:split { direction = "Left", size = 0.25 }
    pane1:send_text([[ ssh -t ca 'zsh -i -c "tm base"' ]] .. "\n")
    pane2:send_text 'ssh ca\n'

    tab, pane1, window = window:spawn_tab {}
    tab:set_title("ca-22")
    pane2 = pane1:split { direction = "Left", size = 0.25 }
    pane1:send_text([[ ssh -t ca-22 'zsh -i -c "tm base"' ]] .. "\n")
    pane2:send_text 'ssh ca-22\n'

    tab, pane1, window = window:spawn_tab {}
    tab:set_title("tmp")
    pane2 = pane1:split { direction = "Left", size = 0.25 }
    pane3 = pane2:split { direction = "Bottom", size = 0.75 }
  elseif hostname == "pyx-22" then
    tab:set_title("pyx")
    pane2 = pane1:split { direction = "Left", size = 0.4 }
    pane1:send_text 'tm base\n'
  elseif hostname == "ca" then
    tab:set_title("ca")
    pane2 = pane1:split { direction = "Left", size = 0.4 }
    pane1:send_text 'tm base\n'
  elseif hostname == "ca-22" then
    tab:set_title("ca-22")
    pane2 = pane1:split { direction = "Left", size = 0.4 }
    pane1:send_text 'tm base\n'
  elseif hostname == "mbp.localdomain" then
    tab:set_title("mbp")
    pane2 = pane1:split { direction = "Left", size = 0.25 }
    pane1:send_text 'tm base\n'
  end

  window:gui_window():perform_action(act.ActivateTab(0), pane1)
end)

return c
