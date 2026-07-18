-- Pure formatting helpers for the which-key panel. No Hammerspoon dependency,
-- so this file is unit tested by which_key_format_spec.lua.
--
-- The single source of truth for the bindings is aerospace.toml, read back at
-- runtime via `aerospace config --get mode.<name>.binding --json`. These
-- functions turn that raw notation -> command map into rows a human can read.

local M = {}

local MOD_SYMBOL = {
  alt = "⌥",
  shift = "⇧",
  ctrl = "⌃",
  cmd = "⌘",
}

-- Notation -> the key as printed on a de-ch (Swiss German) keyboard. AeroSpace
-- binds by physical position (qwerty preset), so several notations carry a
-- different legend on this layout (e.g. slash sits where "-" is printed, and
-- y/z are swapped on QWERTZ).
local KEY_LABEL = {
  slash = "-",
  period = ".",
  comma = ",",
  minus = "'",
  equal = "^",
  semicolon = "ö",
  quote = "ä",
  leftSquareBracket = "ü",
  rightSquareBracket = "¨",
  backslash = "$",
  z = "y",
  y = "z",
  esc = "esc",
  space = "space",
  enter = "enter",
  tab = "tab",
  backspace = "backspace",
}

local function base_label(base)
  return KEY_LABEL[base] or base
end

-- Turn a binding notation such as "shift-1" into a display label such as "⇧1",
-- translating the base key to its de-ch legend.
function M.key_label(notation)
  local mods = {}
  local rest = notation
  while true do
    local mod, tail = rest:match("^(%a+)%-(.+)$")
    if mod and MOD_SYMBOL[mod] then
      mods[#mods + 1] = MOD_SYMBOL[mod]
      rest = tail
    else
      break
    end
  end
  return table.concat(mods) .. base_label(rest)
end

-- Drop the "mode X" plumbing and any which-key panel calls, collapse
-- whitespace, and leave the meaningful action(s).
function M.clean_command(command)
  local parts = {}
  for part in (command .. ";"):gmatch("%s*(.-)%s*;") do
    if
      part ~= ""
      and not part:match("^mode%s")
      and not part:match("whichKey")
    then
      parts[#parts + 1] = part:gsub("%s+", " ")
    end
  end
  return table.concat(parts, " + ")
end

local function basename(path)
  return (path:gsub("^.*/", ""))
end

-- Cosmetic, rule-based label from a cleaned command. A pure function of the
-- string, so it needs no per-binding upkeep.
function M.prettify(command)
  local exact = {
    ["layout tiles horizontal vertical"] = "tiling (h/v)",
    ["layout accordion horizontal vertical"] = "accordion (h/v)",
    ["layout floating tiling"] = "float / tile",
    ["flatten-workspace-tree"] = "reset layout",
    ["balance-sizes"] = "balance sizes",
    ["reload-config"] = "reload config",
    ["close-all-windows-but-current"] = "close others",
    ["close"] = "close window",
    ["fullscreen"] = "fullscreen",
  }
  if exact[command] then
    return exact[command]
  end

  local patterns = {
    { "^workspace%s+(.+)$", "workspace %s" },
    { "^move%-node%-to%-workspace%s+(.+)$", "move to ws %s" },
    { "^join%-with%s+(.+)$", "join %s" },
    { "^resize%s+(.+)$", "resize %s" },
    { "^focus%s+(.+)$", "focus %s" },
    { "^move%s+(.+)$", "move %s" },
  }
  for _, rule in ipairs(patterns) do
    local arg = command:match(rule[1])
    if arg then
      return rule[2]:format(arg)
    end
  end

  local exec = command:match("^exec%-and%-forget%s+(.+)$")
  if exec then
    return "run " .. basename(exec)
  end

  return command
end

-- Full row text for a binding. A bare "mode main" (with no other action) is a
-- cancel key; a bare switch to another mode reads as an arrow to that mode.
function M.describe(command)
  local desc = M.prettify(M.clean_command(command))
  if desc ~= "" then
    return desc
  end
  if command:match("^%s*mode main%s*$") then
    return "cancel"
  end
  local sub = command:match("mode%s+(%S+)")
  if sub then
    return "→ " .. sub .. " mode"
  end
  return ""
end

local function group_rank(base)
  if base:match("^%d$") then
    return 1
  elseif base:match("^%a$") then
    return 2
  end
  return 3
end

-- Order rows: unmodified keys first, then by kind (digit, letter, special),
-- then by notation, so 1-9 come before shift-1..9 and letters before symbols.
local function sort_tuple(notation)
  local base = notation:match("([^%-]+)$") or notation
  return {
    notation:find("%-") and 1 or 0,
    group_rank(base),
    notation,
  }
end

function M.build_rows(binding)
  local rows = {}
  for notation, command in pairs(binding) do
    rows[#rows + 1] = {
      key = M.key_label(notation),
      desc = M.describe(command),
      notation = notation,
    }
  end
  table.sort(rows, function(a, b)
    local ta, tb = sort_tuple(a.notation), sort_tuple(b.notation)
    for i = 1, 3 do
      if ta[i] ~= tb[i] then
        return ta[i] < tb[i]
      end
    end
    return false
  end)
  return rows
end

return M
