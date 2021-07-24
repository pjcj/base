Opt.autowriteall  = true
Opt.backspace     = { "indent", "eol", "start" }
Opt.backup        = true
Opt.backupcopy    = { "yes", "breakhardlink" }
Opt.backupdir     = Opt.backupdir - { "." }
Opt.backupext     = ".bak"
Opt.clipboard     = { }
Opt.cmdheight     = 3
Opt.colorcolumn   = { 80, 120 }
Opt.complete      = ".,w,b,u,U,k/usr/share/dict/*,i,t"
Opt.completeopt   = "menuone,noselect"
Opt.diffopt       = { "internal", "filler", "vertical" }
Opt.expandtab     = true
Opt.fillchars     = "fold: "
Opt.formatoptions = "tcrqnlj"
Opt.ignorecase    = true
Opt.inccommand    = "split"
Opt.list          = true
Opt.matchpairs    = Opt.matchpairs + { "<:>" }
Opt.mouse         = "a"
Opt.mousefocus    = true
Opt.number        = true
Opt.report        = 0
Opt.scrolloff     = 5
Opt.shiftround    = true
Opt.shiftwidth    = 2
Opt.shortmess     = Opt.shortmess + { c = true }
Opt.showmatch     = true
Opt.signcolumn    = "auto:1"
Opt.smartcase     = true
Opt.smarttab      = true
Opt.title         = true
Opt.undofile      = true
Opt.undolevels    = 10000
Opt.updatecount   = 40
Opt.updatetime    = 250
Opt.wildmode      = "longest:full,full"
Opt.wildoptions   = "pum,tagfile"

if Fn.executable("rg") then
  Opt.grepprg    = "rg --no-heading --hidden --glob '!.git' --vimgrep"
  Opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
else
  Opt.grepprg    = "git grep -n"
end

local alternate_indent = function()
  G.indent_blankline_char_highlight_list       = { "IndentOdd", "IndentEven" }
  G.indent_blankline_space_char_highlight_list = { "IndentOdd", "IndentEven" }
end

function _G.set_buffer_settings()
  local ft = vim.bo.filetype

  if ft == "go" or ft == "make" then
    Lopt.listchars  = { tab = "  ", trail = "·" }
    Lopt.tabstop    = 2
    Lopt.shiftwidth = 2
    alternate_indent()

    if ft == "go" then
      Bmap(0, "n", "<leader>oa", "<cmd>GoAlternate<cr>",     Defmap)
      Bmap(0, "n", "<leader>oi", "<cmd>GoImports<cr>",       Defmap)
      Bmap(0, "n", "<leader>os", "<cmd>GoSameIdsToggle<cr>", Defmap)
    end
    return
  end
  Lopt.listchars = { tab = "» ", trail = "·" }
  Lopt.tabstop   = 8
  if vim.bo.shiftwidth < 3 then
    alternate_indent()
  else
    G.indent_blankline_char_highlight_list       = { "IndentEven"  }
    G.indent_blankline_space_char_highlight_list = { "IndentSpace" }
  end

  if ft == "gitcommit" then
    Lopt.colorcolumn = { 50, 72 }
    Lopt.textwidth   = 72
    Lopt.spell       = true
    Lopt.spelllang   = "en_gb"
  end

  if ft == "perl" then
    Map("n", "<F4>",       [[:execute "tjump /^\\(_build_\\)\\?" . expand("<cword>") . "$"<cr>]], Defmap)
    Map("i", "<F2>",       "sub ($self) {<CR>}<ESC>kea<Space>", Defmap)
    Map("i", "<F3>",       "$self->{}<ESC>i",                   Defmap)
    Map("i", "<F4>",       "$self->",                           Defmap)
    Cmd([[iabbr ,, =>]])
  end
end
