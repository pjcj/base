-- Run with: nvim -l tests/accept_word_test.lua (from .config/nvim)

package.path = package.path
  .. ";"
  .. vim.fn.fnamemodify(arg[0], ":p:h:h")
  .. "/lua/?.lua"

local next_chunk = require("accept_word").next_chunk

local tests = {
  {
    name = "supermaven full-line newText with skewed range start",
    first_line = 'elseif ctx.source_name == "copilot" then',
    line = "  elseif",
    cursor_col = 8,
    range_start = 4,
    expect = " ctx",
  },
  {
    name = "supermaven full-line newText including indent, start 0",
    first_line = '  elseif ctx.source_name == "copilot" then',
    line = "  elseif",
    cursor_col = 8,
    range_start = 0,
    expect = " ctx",
  },
  {
    name = "lsp item, mid-word",
    first_line = "elseif_chain",
    line = "  els",
    cursor_col = 5,
    range_start = 2,
    expect = "eif_chain",
  },
  {
    name = "lsp item, at word boundary",
    first_line = "elseif ctx.kind then",
    line = "  elseif",
    cursor_col = 8,
    range_start = 2,
    expect = " ctx",
  },
  {
    name = "punctuation before next word is included",
    first_line = "ctx.source_name",
    line = "  ctx",
    cursor_col = 5,
    range_start = 2,
    expect = ".source_name",
  },
  {
    name = "nothing left to insert",
    first_line = "elseif",
    line = "  elseif",
    cursor_col = 8,
    range_start = 2,
    expect = nil,
  },
}

local failures = 0
for _, t in ipairs(tests) do
  local got = next_chunk(t.first_line, t.line, t.cursor_col, t.range_start)
  if got ~= t.expect then
    failures = failures + 1
    print(
      ("FAIL %s: expected %s, got %s"):format(
        t.name,
        vim.inspect(t.expect),
        vim.inspect(got)
      )
    )
  else
    print("ok   " .. t.name)
  end
end

if failures > 0 then
  print(failures .. " test(s) failed")
  os.exit(1)
end
print("all tests passed")
