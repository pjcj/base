-- Extract the next word of a completion item's text for word-wise accept.
--
-- Sources disagree about what their text edit covers: LSP items replace from
-- the keyword start, while AI sources such as Supermaven replace the whole
-- line and sometimes report a skewed range start. Range arithmetic alone
-- therefore cannot locate the cursor within the completion text. Instead,
-- find the longest suffix of the text before the cursor that is a prefix of
-- the completion line and continue from there, falling back to the range
-- arithmetic only when nothing matches.

local M = {}

local function cut_position(first_line, before, cursor_col, range_start)
  for len = #before, 1, -1 do
    if first_line:sub(1, len) == before:sub(#before - len + 1) then
      return len
    end
  end
  return math.max(0, cursor_col - range_start)
end

--- Return the next word of first_line to insert at the cursor, or nil.
--- @param first_line string first line of the completion's newText
--- @param line string current buffer line
--- @param cursor_col number 0-indexed byte column of the cursor
--- @param range_start number 0-indexed start character of the text edit
--- @return string|nil
function M.next_chunk(first_line, line, cursor_col, range_start)
  local before = line:sub(1, cursor_col)
  local cut = cut_position(first_line, before, cursor_col, range_start)
  local after_cursor = first_line:sub(cut + 1)

  local chunk
  if after_cursor:match("^[%w_]") then
    chunk = after_cursor:match("^([%w_]+)")
  else
    chunk = after_cursor:match("^(%W*[%w_]+)")
  end
  if chunk == "" then return nil end
  return chunk
end

return M
