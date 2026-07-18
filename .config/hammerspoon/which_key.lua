--# selene: allow(undefined_variable)

-- A which-key style hint panel for AeroSpace binding modes.
--
-- AeroSpace owns the mode state and remains the window manager. This module
-- only draws a floating panel and hides it. On show() it asks AeroSpace for the
-- live bindings of the given mode, so the panel can never disagree with the
-- real keymap - aerospace.toml is the single source of truth.
--
-- Driven from aerospace.toml over IPC, e.g.
--   exec-and-forget /opt/homebrew/bin/hs -c "whichKey:show('op')"

local fmt = require("which_key_format")

local M = {}

local AEROSPACE = "/opt/homebrew/bin/aerospace"
local AUTO_HIDE = 8 -- seconds, backstop against an orphaned panel

local canvas = nil
local timer = nil
local tap = nil

-- Solarized-dark palette, with the border matching the JankyBorders active
-- colour used in aerospace.toml.
local COLOR = {
  bg = { red = 0.0, green = 0.169, blue = 0.212, alpha = 0.94 },
  border = { red = 0.427, green = 0.827, blue = 0.455, alpha = 1.0 },
  title = { red = 0.427, green = 0.827, blue = 0.455, alpha = 1.0 },
  key = { red = 0.710, green = 0.537, blue = 0.0, alpha = 1.0 },
  desc = { red = 0.514, green = 0.580, blue = 0.588, alpha = 1.0 },
}

local function query_binding(mode)
  local cmd = string.format(
    "%s config --get mode.%s.binding --json 2>/dev/null",
    AEROSPACE,
    mode
  )
  local out = hs.execute(cmd)
  if not out or out == "" then
    return nil
  end
  local ok, decoded = pcall(hs.json.decode, out)
  if ok and type(decoded) == "table" then
    return decoded
  end
  return nil
end

local function draw(rows, mode)
  local screen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
  local frame = screen:frame()

  local pad = 18
  local titleH = 26
  local rowH = 22
  local keyW = 60
  local descW = 200
  local colGap = 24
  local colCount = (#rows > 10) and 2 or 1
  local perCol = math.ceil(#rows / colCount)
  local colW = keyW + descW

  local width = pad * 2 + colW * colCount + colGap * (colCount - 1)
  local height = pad * 2 + titleH + perCol * rowH
  local x = frame.x + (frame.w - width) / 2
  local y = frame.y + (frame.h - height) / 2

  local radii = { xRadius = 12, yRadius = 12 }
  local elements = {
    {
      type = "rectangle",
      action = "fill",
      fillColor = COLOR.bg,
      roundedRectRadii = radii,
    },
    {
      type = "rectangle",
      action = "stroke",
      strokeColor = COLOR.border,
      strokeWidth = 2,
      roundedRectRadii = radii,
    },
    {
      type = "text",
      text = mode .. " mode",
      textFont = "Menlo-Bold",
      textSize = 15,
      textColor = COLOR.title,
      textAlignment = "center",
      frame = { x = pad, y = pad - 6, w = width - pad * 2, h = titleH },
    },
  }

  for i, row in ipairs(rows) do
    local col = math.floor((i - 1) / perCol)
    local within = (i - 1) % perCol
    local cx = pad + col * (colW + colGap)
    local cy = pad + titleH + within * rowH
    elements[#elements + 1] = {
      type = "text",
      text = row.key,
      textFont = "Menlo-Bold",
      textSize = 13,
      textColor = COLOR.key,
      textAlignment = "right",
      frame = { x = cx, y = cy, w = keyW - 10, h = rowH },
    }
    elements[#elements + 1] = {
      type = "text",
      text = row.desc,
      textFont = "Menlo",
      textSize = 13,
      textColor = COLOR.desc,
      frame = { x = cx + keyW, y = cy, w = descW, h = rowH },
    }
  end

  canvas = hs.canvas.new({ x = x, y = y, w = width, h = height })
  canvas:level(hs.canvas.windowLevels.overlay)
  canvas:behaviorAsLabels({ "canJoinAllSpaces", "stationary" })
  canvas:appendElements(elements)
  canvas:show()
end

-- Dismiss on the next keypress or click. We watch keyDown (not keyUp), so
-- releasing the leader chord does not close the panel prematurely. The timer
-- is a backstop for the idle case and for any key AeroSpace consumes before
-- this watcher sees it.
local function start_dismiss_watch()
  tap = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.leftMouseDown,
  }, function()
    M.hide()
    return false
  end)
  tap:start()
end

function M.hide()
  if timer then
    timer:stop()
    timer = nil
  end
  if tap then
    tap:stop()
    tap = nil
  end
  if canvas then
    canvas:delete()
    canvas = nil
  end
end

-- Colon method: callers use whichKey:show('op'), so the mode arrives after the
-- implicit self.
function M:show(mode)
  mode = mode or "main"
  local binding = query_binding(mode)
  if not binding or next(binding) == nil then
    return
  end
  M.hide()
  draw(fmt.build_rows(binding), mode)
  -- Timer first, so the panel still auto-hides even if the keypress watcher
  -- cannot start (for example before Accessibility is granted).
  timer = hs.timer.doAfter(AUTO_HIDE, function()
    M.hide()
  end)
  pcall(start_dismiss_watch)
end

return M
