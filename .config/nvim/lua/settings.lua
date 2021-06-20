local cmd  = vim.cmd        -- run Vim commands
local fn   = vim.fn         -- call Vim functions
local g    = vim.g          -- a table to access global variables
local opt  = vim.opt        -- set options
local lopt = vim.opt_local  -- set local options
local api  = vim.api        -- vim api
local exec = api.nvim_exec  -- execute nvim

opt.autowriteall  = true
opt.backspace     = { "indent", "eol", "start" }
opt.backup        = true
opt.backupcopy    = { "yes", "breakhardlink" }
opt.backupdir     = opt.backupdir - { "." }
opt.backupext     = ".bak"
opt.clipboard     = { }
opt.cmdheight     = 3
opt.colorcolumn   = { 80, 120 }
opt.complete      = ".,w,b,u,U,k/usr/share/dict/*,i,t"
opt.completeopt   = "menuone,noselect"
opt.diffopt       = { "internal", "filler", "vertical" }
opt.expandtab     = true
opt.fillchars     = "fold: "
opt.formatoptions = "tcrqnlj"
opt.ignorecase    = true
opt.inccommand    = "split"
opt.list          = true
opt.matchpairs    = opt.matchpairs + { "<:>" }
opt.mouse         = "a"
opt.mousefocus    = true
opt.number        = true
opt.report        = 0
opt.scrolloff     = 5
opt.shiftround    = true
opt.shiftwidth    = 2
opt.shortmess     = opt.shortmess + { c = true }
opt.showmatch     = true
opt.signcolumn    = "number"
opt.smartcase     = true
opt.title         = true
opt.undofile      = true
opt.undolevels    = 10000
opt.updatecount   = 40
opt.updatetime    = 250
opt.wildmode      = "longest:full,full"
opt.wildoptions   = "pum,tagfile"

if fn.executable("rg") then
  opt.grepprg    = "rg --no-heading --hidden --glob '!.git' --vimgrep"
  opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
else
  opt.grepprg    = "git grep -n"
end

local alternate_indent = function()
  g.indent_blankline_char_highlight_list       = { "IndentOdd", "IndentEven" }
  g.indent_blankline_space_char_highlight_list = { "IndentOdd", "IndentEven" }
end

function _G.set_buffer_settings()
  local ft = vim.bo.filetype

  if ft == "go" or ft == "make" then
    lopt.listchars = { tab = "  ", trail = "·" }
    lopt.tabstop   = 2
    alternate_indent()
    return
  end
  lopt.listchars = { tab = "» ", trail = "·" }
  lopt.tabstop   = 8
  if vim.bo.shiftwidth < 3 then
    alternate_indent()
  else
    g.indent_blankline_char_highlight_list       = { "IndentEven"  }
    g.indent_blankline_space_char_highlight_list = { "IndentSpace" }
  end

  if ft == "gitcommit" then
    lopt.colorcolumn = { 50, 72 }
    lopt.textwidth   = 72
    lopt.spell       = true
    lopt.spelllang   = "en_gb"
  end
end
