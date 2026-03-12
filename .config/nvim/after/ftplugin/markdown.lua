vim.bo.comments = "n:>"
vim.bo.formatlistpat = [[^\s*[-*+]\s\+\|\s*\d\+[.)]\s\+]]
vim.bo.indentexpr = ""

vim.bo.formatexpr = "v:lua.MdFormatExpr()"

function MdFormatExpr()
  if vim.fn.mode() == "i" then return 1 end
  local start_line = vim.v.lnum
  local end_line = start_line + vim.v.count - 1
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  local trailing = {}
  while #lines > 0 and lines[#lines]:match("^%s*$") do
    table.insert(trailing, 1, table.remove(lines))
  end
  if #lines == 0 then return 0 end

  local input = table.concat(lines, "\n") .. "\n"
  local result = vim.fn.system("mdformat --number --wrap 80 -", input)
  local new_lines = vim.split(result, "\n", { trimempty = false })

  while #new_lines > 0 and new_lines[#new_lines] == "" do
    table.remove(new_lines)
  end

  for _, l in ipairs(trailing) do
    table.insert(new_lines, l)
  end

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
  return 0
end
