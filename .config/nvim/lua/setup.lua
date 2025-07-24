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
  local l = require("local_defs")
  local c = l.colour
  vim.g.devel_cover_bg = c.base03
  vim.g.devel_cover_fg = c.rgreen
  -- vim.g.devel_cover_valid_bg = c.base05
  -- vim.g.devel_cover_error_bg = c.dred
  vim.g.devel_cover_error_fg = c.red
  vim.g.devel_cover_old_bg = c.ddviolet
  -- vim.g.devel_cover_cterm = "NONE"
  -- vim.g.devel_cover_gui = "NONE"

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
    statement = "● ", -- Medium bullet
    branch = "⅄ ",
    condition = "⊤ ",
  }
end

-- Auto-execute coverage.lua when it changes
local function setup_coverage_auto_execute()
  local last_mtime = nil
  local coverage_file = "cover_db/coverage.lua"

  local function check_and_execute_coverage()
    -- Only check if we have at least one Perl buffer
    local has_perl_buffer = false
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if ft == "perl" or ft == "perl6" or ft == "raku" then
          has_perl_buffer = true
          break
        end
      end
    end

    if not has_perl_buffer then
      vim.notify("No Perl buffers, skipping coverage check", vim.log.levels.DEBUG)
      return
    end

    local mtime = vim.fn.getftime(coverage_file)
    vim.notify(
      "Checking " .. coverage_file .. " mtime=" .. tostring(mtime),
      vim.log.levels.DEBUG
    )

    if mtime > 0 then
      -- File exists, check if it's changed
      vim.notify(
        "File exists. last_mtime="
          .. tostring(last_mtime)
          .. " current_mtime="
          .. tostring(mtime),
        vim.log.levels.DEBUG
      )

      if last_mtime == nil or mtime ~= last_mtime then
        last_mtime = mtime
        vim.notify(
          "Executing " .. coverage_file .. " (mtime changed)",
          vim.log.levels.INFO
        )

        -- Execute the coverage file for all Perl buffers
        vim.schedule(function()
          local ok, err = pcall(dofile, coverage_file)
          if not ok then
            vim.notify(
              "Error executing coverage.lua: " .. tostring(err),
              vim.log.levels.ERROR
            )
          else
            vim.notify(
              "Successfully executed " .. coverage_file,
              vim.log.levels.INFO
            )
          end
        end)
      else
        vim.notify("File unchanged, skipping execution", vim.log.levels.DEBUG)
      end
    else
      -- File doesn't exist, reset last_mtime
      if last_mtime ~= nil then
        vim.notify(
          "File no longer exists, resetting mtime",
          vim.log.levels.DEBUG
        )
      end
      last_mtime = nil
    end
  end

  -- Set up timer with proper repeat syntax
  local timer_id = vim.fn.timer_start(5000, function()
    vim.schedule(check_and_execute_coverage)
  end, { ["repeat"] = -1 })

  vim.notify(
    "Coverage auto-execute timer started (id=" .. timer_id .. ", 5 second interval)",
    vim.log.levels.INFO
  )

  -- Check when opening Perl buffers
  vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = {"*.pl", "*.pm", "*.t", "*.pod"},
    callback = function()
      vim.notify("Perl buffer opened, checking coverage", vim.log.levels.DEBUG)
      check_and_execute_coverage()
    end,
    desc = "Check coverage when opening Perl files",
  })

  -- Also check when filetype is set to perl
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {"perl", "perl6", "raku"},
    callback = function()
      vim.notify("Perl filetype set, checking coverage", vim.log.levels.DEBUG)
      check_and_execute_coverage()
    end,
    desc = "Check coverage when filetype is set to perl",
  })

  -- Also check immediately on startup
  check_and_execute_coverage()
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
      setup_coverage_auto_execute()
    end,
    desc = "Setup auto-refresh for file changes and coverage monitoring",
  })
end

-- Execute main setup
main()
