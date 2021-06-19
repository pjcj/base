local cmd  = vim.cmd        -- run Vim commands
local fn   = vim.fn         -- call Vim functions
local g    = vim.g          -- a table to access global variables
local opt  = vim.opt        -- set options
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

function _G.set_buffer_settings()
    local bo=vim.bo
  local ft = vim.bo.filetype
  if ft == "go" or ft == "make" then
    vim.opt_local.listchars = { tab = "  ", trail = "·" }
    vim.opt_local.tabstop   = 2
  else
    vim.opt_local.listchars = { tab = "» ", trail = "·" }
    vim.opt_local.tabstop   = 8
  end
end
