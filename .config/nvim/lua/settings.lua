local vopt = vim.opt -- set options

-- stylua: ignore start
vopt.autoread      = true
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
vopt.titlestring   = "%t"
vopt.undofile      = true
vopt.undolevels    = 10000
vopt.updatecount   = 40
vopt.updatetime    = 250
vopt.wildmode      = "longest:full,full"
vopt.wildoptions   = "pum,tagfile"
vopt.guicursor     = "n-v-c:block-Cursor,i-ci-ve:ver25,r-cr:hor20,o:hor50," ..
                    "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor," ..
                    "sm:block-blinkwait175-blinkoff150-blinkon175"
-- stylua: ignore end

-- Temporarily increase cmdheight during session loading to prevent
-- "Press ENTER" prompts
if vim.v.argv and vim.tbl_contains(vim.v.argv, "-S") then
  vim.opt.cmdheight = 1
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.defer_fn(function()
        vim.opt.cmdheight = 0
      end, 100)
    end,
  })
end

if vim.fn.executable("rg") then
  vopt.grepprg = "rg --no-heading --hidden --glob '!.git' --vimgrep"
  vopt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
else
  vopt.grepprg = "git grep -n"
end

-- Auto-refresh buffers when files change on disk
-- Only affects visible buffers with no unsaved changes
local function setup_auto_refresh()
  local function refresh_visible_buffers()
    -- Get all visible buffers (buffers currently displayed in windows)
    local visible_buffers = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      visible_buffers[buf] = true
    end

    -- Check each visible buffer for file changes
    for buf, _ in pairs(visible_buffers) do
      if vim.api.nvim_buf_is_valid(buf) then
        local buf_name = vim.api.nvim_buf_get_name(buf)
        -- Only refresh if buffer has a file, is not modified, and file exists
        if
          buf_name ~= ""
          and not vim.bo[buf].modified
          and vim.fn.filereadable(buf_name) == 1
        then
          vim.cmd.checktime()
        end
      end
    end
  end

  -- Use vim.fn.timer_start for compatibility
  vim.fn.timer_start(2000, function()
    vim.schedule(refresh_visible_buffers)
  end, { ["repeat"] = -1 })
end

-- Set up auto-refresh after VimEnter to ensure everything is initialised
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    setup_auto_refresh()
  end,
  desc = "Setup auto-refresh for file changes",
})
