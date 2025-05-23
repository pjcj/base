function Perl_select_subroutine()
  local parser = vim.treesitter.get_parser(0, "perl")
  local tree = parser:parse()[1]
  local root = tree:root()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_range = { cursor[1] - 1, cursor[2] }

  local node = root:named_descendant_for_range(
    cursor_range[1],
    cursor_range[2],
    cursor_range[1],
    cursor_range[2]
  )

  while node and node:type() ~= "subroutine_declaration_statement" do
    node = node:parent()
  end

  if not node or node:type() ~= "subroutine_declaration_statement" then
    print("No subroutine found at cursor.")
    return false
  end

  local srow, scol, erow, ecol = node:range()
  srow, scol, erow, ecol = srow + 1, scol + 1, erow + 1, ecol + 1
  vim.api.nvim_buf_set_mark(0, "<", srow, scol, {})
  vim.api.nvim_buf_set_mark(0, ">", erow, ecol, {})
  vim.cmd("normal! `<V`>")
  return true
end

function Perl_format_sub()
  if Perl_select_subroutine() then
    vim.api.nvim_input("glf<esc>")
  end
end

require("which-key").add({
  {
    "<leader>,ps",
    function()
      Perl_select_subroutine()
    end,
    desc = "select subroutine",
  },
  {
    "<leader>,pp",
    function()
      Perl_format_sub()
    end,
    desc = "format subroutine",
  },
  {
    "<leader>,pi",
    function()
      local vopt = vim.opt
      vopt.shiftwidth = 2
      vopt.tabstop = 2
      vopt.expandtab = true
    end,
    desc = "set indentation",
  },
  {
    mode = "i",
    { "<F2>", "sub ($self) {<cr>}<esc>kea<space>", desc = "new sub" },
    { "<F4>", "$self->", desc = "$self->" },
    { "<S-F4>", "->", desc = "->" },
  },
})

vim.opt_local.formatoptions = "tcrqnljp"

local perl_inc_dirs =
  table.concat(require("local_defs").fn.perl_inc_dirs(), ",")

-- Prepend the custom paths to the global default path for this buffer.
-- This avoids repeatedly adding paths if the ftplugin is sourced multiple times.
vim.bo.path = perl_inc_dirs .. "," .. vim.go.path
