-- Unit tests for the pure formatting logic behind the which-key panel.
-- Run: luajit which_key_format_spec.lua   (or: lua which_key_format_spec.lua)

local dir = arg[0]:match("^(.*/)") or "./"
package.path = dir .. "?.lua;" .. package.path
local fmt = require("which_key_format")

local failures = 0

local function eq(got, want, name)
  if got ~= want then
    failures = failures + 1
    io.write(
      string.format(
        "FAIL %s\n  got:  %s\n  want: %s\n",
        name,
        tostring(got),
        tostring(want)
      )
    )
  else
    io.write("ok   " .. name .. "\n")
  end
end

-- clean_command: drop the "mode X" plumbing, collapse whitespace
eq(
  fmt.clean_command("layout tiles horizontal vertical; mode main"),
  "layout tiles horizontal vertical",
  "clean drops trailing mode main"
)
eq(
  fmt.clean_command("exec-and-forget  ~/g/base/utils/toggle_audio; mode main"),
  "exec-and-forget ~/g/base/utils/toggle_audio",
  "clean collapses repeated spaces"
)
eq(
  fmt.clean_command("fullscreen; mode main"),
  "fullscreen",
  "clean single verb"
)

-- prettify: rule-based friendly labels, pure function of the command
eq(
  fmt.prettify("layout tiles horizontal vertical"),
  "tiling (h/v)",
  "pretty tiles toggle"
)
eq(
  fmt.prettify("layout accordion horizontal vertical"),
  "accordion (h/v)",
  "pretty accordion toggle"
)
eq(fmt.prettify("workspace 1"), "workspace 1", "pretty workspace")
eq(fmt.prettify("move-node-to-workspace 3"), "move to ws 3", "pretty move node")
eq(
  fmt.prettify("exec-and-forget ~/g/base/utils/toggle_audio"),
  "run toggle_audio",
  "pretty exec basename"
)
eq(fmt.prettify("fullscreen"), "fullscreen", "pretty passthrough")
eq(fmt.prettify("join-with right"), "join right", "pretty join-with")

-- describe: full command -> row text, with bare mode-returns read as cancel
eq(
  fmt.describe("workspace 1; mode main"),
  "workspace 1",
  "describe real command"
)
eq(fmt.describe("mode main"), "cancel", "describe bare mode main is cancel")

-- key_label: notation -> the legend on a de-ch (Swiss German) keyboard
eq(fmt.key_label("slash"), "-", "de-ch slash prints minus")
eq(fmt.key_label("period"), ".", "de-ch period unchanged")
eq(fmt.key_label("z"), "y", "de-ch z/y swap")
eq(fmt.key_label("1"), "1", "digit unchanged")
eq(fmt.key_label("shift-1"), "⇧1", "shifted digit")
eq(fmt.key_label("esc"), "esc", "esc label")

-- build_rows: sorted rows with rendered key + description
local rows = fmt.build_rows({
  ["1"] = "workspace 1; mode main",
  ["shift-1"] = "move-node-to-workspace 1; mode main",
  ["slash"] = "layout tiles horizontal vertical; mode main",
  ["z"] = "fullscreen; mode main",
})
eq(rows[1].key, "1", "first row is unmodified digit")
eq(rows[1].desc, "workspace 1", "first row description")
eq(rows[#rows].key, "⇧1", "last row is modified key")

if failures > 0 then
  io.write(string.format("\n%d failure(s)\n", failures))
  os.exit(1)
end
io.write("\nall passed\n")
