local vopt = vim.opt -- set options

-- Configure cmdheight during session loading to prevent "Press ENTER" prompts
local function setup_cmdheight_for_session()
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
end

-- Configure grep program based on available tools
local function setup_grep_program()
  if vim.fn.executable("rg") then
    vopt.grepprg = "rg --no-heading --hidden --glob '!.git' --vimgrep"
    vopt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
  else
    vopt.grepprg = "git grep -n"
  end
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

-- Configure Devel::Cover highlights and signs for Perl code coverage
local function setup_devel_cover_highlights()
  vim.g.devel_cover_bg = "#002b36" -- dark for covered
  vim.g.devel_cover_fg = "#859900" -- solarized green
  vim.g.devel_cover_valid_bg = "#002b36" -- dark for covered
  vim.g.devel_cover_error_bg = "#2d1616" -- dark red for uncovered
  vim.g.devel_cover_error_fg = "#dc322f" -- solarized red
  vim.g.devel_cover_old_bg = "#342a2a" -- darker red-tinted background
  vim.g.devel_cover_cterm = "NONE"
  vim.g.devel_cover_gui = "NONE"

  -- Custom sign characters (optional)
  -- vim.g.devel_cover_signs = {
  --   pod = "📖",
  --   subroutine = "🔧",
  --   statement = "📝",
  --   branch = "🌿",
  --   condition = "❓"
  -- }
  vim.g.devel_cover_signs = {
    pod = "¶ ",
    subroutine = "ƒ ",
    statement = "• ", -- Small bullet (unobtrusive)
    branch = "» ",
    condition = "? ",
  }
end

-- Main setup function
local function main()
  setup_cmdheight_for_session()
  setup_grep_program()
  setup_devel_cover_highlights()

  -- Set up auto-refresh after VimEnter to ensure everything is initialised
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      setup_auto_refresh()
    end,
    desc = "Setup auto-refresh for file changes",
  })
end

-- Execute main setup
main()
