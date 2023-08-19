local wezterm = require "wezterm"
local config = {}

config.term = "wezterm"

config.font = wezterm.font("Inconsolata NF")
config.font_size = 16

-- config.color_scheme = "Solarized Dark - Patched"
config.colors = {
  background = "#001920",
  foreground = "#93A1A1",
  cursor_bg = "#dc322f",
  cursor_fg = "#001920",
  cursor_border = "#586e75",
  compose_cursor = "#de860e",
  selection_bg = "#f0a63f",
  selection_fg = "#001920",
  ansi = {
    "#001920",
    "#dc322f",
    "#25ad2e",
    "#b58900",
    "#268bd2",
    "#d33682",
    "#2aa198",
    "#eee8d5",
  },
  brights = {
    "#022731",
    "#cb4b16",
    "#586e75",
    "#657b83",
    "#839496",
    "#6c71c4",
    "#93a1a1",
    "#fdf6e3",
  },
}

config.adjust_window_size_when_changing_font_size = false

config.keys = {
  { key = "+", mods = "CTRL", action = "IncreaseFontSize" },
  { key = "-", mods = "CTRL", action = "DecreaseFontSize" },
}

config.window_decorations = "RESIZE"

config.ssh_domains = {
  {
    name = "pyx",
    remote_address = "10.20.30.3",
    username = "pjcj",
    ssh_option = {
      IdentityFile = "/mnt/c/Users/pjcj/.ssh/id_ed25519",
    }
  },
}
config.default_domain = "WSL:Ubuntu"
config.unix_domains = {
  {
    name = "unix",
  }
}

return config
