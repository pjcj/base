local vopt = vim.opt  -- set options

vopt.autowriteall  = true
vopt.backspace     = { "indent", "eol", "start" }
vopt.background    = "dark"
vopt.backup        = true
vopt.backupcopy    = { "yes", "breakhardlink" }
vopt.backupdir     = vopt.backupdir - { "." }
vopt.backupext     = ".bak"
vopt.clipboard     = { }
vopt.cmdheight     = 0
vopt.colorcolumn   = { 80, 120 }
vopt.complete      = ".,w,b,u,U,k/usr/share/dict/*,i,t"
vopt.completeopt   = "menuone,noselect"
vopt.diffopt       = { "internal", "filler", "vertical" }
vopt.expandtab     = true
vopt.fillchars     = "fold: "
vopt.formatoptions = "tcrqnljp"
vopt.ignorecase    = true
vopt.inccommand    = "split"
vopt.list          = true
vopt.listchars     = { tab = "» ", trail = "·", nbsp = "␣" }
vopt.matchpairs    = vopt.matchpairs + { "<:>" }
vopt.mouse         = "a"
vopt.mousefocus    = true
vopt.number        = true
vopt.report        = 0
vopt.scrolloff     = 5
vopt.shiftround    = true
vopt.shiftwidth    = 2
vopt.shortmess     = vopt.shortmess + { c = true }
vopt.showmatch     = true
vopt.signcolumn    = "yes:1"
vopt.smartcase     = true
vopt.smarttab      = true
vopt.splitbelow    = true
vopt.splitright    = true
vopt.termguicolors = true
vopt.title         = true
vopt.undofile      = true
vopt.undolevels    = 10000
vopt.updatecount   = 40
vopt.updatetime    = 250
vopt.wildmode      = "longest:full,full"
vopt.wildoptions   = "pum,tagfile"
vopt.guicursor     = "n-v-c:block-Cursor,i-ci-ve:ver25,r-cr:hor20,o:hor50," ..
                    "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor," ..
                    "sm:block-blinkwait175-blinkoff150-blinkon175"

if vim.fn.executable("rg") then
  vopt.grepprg    = "rg --no-heading --hidden --glob '!.git' --vimgrep"
  vopt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
else
  vopt.grepprg    = "git grep -n"
end
