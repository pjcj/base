--# selene: allow(undefined_variable)

-- Hammerspoon entry point for the AeroSpace which-key panel.
--
-- AeroSpace triggers the panel over the hammerspoon:// URL scheme, e.g.
--   open -g "hammerspoon://whichkey-show?mode=op"
-- which needs no command-line tool or IPC message port. The module is also
-- published as a global so it can be driven from the Hammerspoon Console.

_G.whichKey = require("which_key")

hs.urlevent.bind(
  "whichkey-show",
  function(_, params) _G.whichKey:show((params and params.mode) or "op") end
)

hs.urlevent.bind("whichkey-hide", function() _G.whichKey:hide() end)

hs.alert.show("Hammerspoon which-key loaded")
