-- Create autocommand groups
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Yank highlight
augroup("yank_highlight", { clear = true })
autocmd("TextYankPost", {
  group = "yank_highlight",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "Cursor", timeout = 1000 })
  end,
})

-- Buffer enter
augroup("buf_enter", { clear = true })
autocmd("BufWinEnter", {
  group = "buf_enter",
  pattern = "*",
  callback = function() require("local_defs").fn.set_buffer_settings() end,
})

-- Autowrite
augroup("autowrite", { clear = true })
autocmd({ "FocusLost", "BufLeave" }, {
  group = "autowrite",
  pattern = "*",
  command = "silent! wa",
})

-- File types
augroup("file_types", { clear = true })
autocmd({ "BufNewFile", "BufReadPost" }, {
  group = "file_types",
  pattern = "*.t",
  command = "set ft=perl",
})
autocmd({ "BufNewFile", "BufReadPost" }, {
  group = "file_types",
  pattern = "*.mc",
  command = "set ft=mason",
})
autocmd({ "BufNewFile", "BufReadPost" }, {
  group = "file_types",
  pattern = "template/**",
  command = "set ft=tt2html",
})
autocmd({ "BufNewFile", "BufReadPost" }, {
  group = "file_types",
  pattern = "*.tt2",
  command = "set ft=tt2html",
})
autocmd({ "BufNewFile", "BufReadPost" }, {
  group = "file_types",
  pattern = "*.tt",
  command = "set ft=tt2html",
})

-- Quickfix
augroup("quickfix", { clear = true })
autocmd("FileType", {
  group = "quickfix",
  pattern = "qf",
  command = "setlocal winheight=20",
})

-- Git commit
augroup("git_commit", { clear = true })
autocmd("User", {
  group = "git_commit",
  pattern = "FugitiveChanged",
  once = true,
  callback = function()
    -- Check if we just completed a commit
    local result = vim.fn.FugitiveResult()
    if result.args and vim.tbl_contains(result.args, "commit") then
      if result.exit_status ~= 0 then
        vim.notify(
          "Git commit failed with exit status: " .. result.exit_status,
          vim.log.levels.ERROR
        )
      end
    end
  end,
})

autocmd("FileType", {
  group = "git_commit",
  pattern = "gitcommit",
  callback = function()
    -- Set cmdheight for better visibility during commit
    vim.opt.cmdheight = 2

    -- Add blank line if needed and start insert mode
    if vim.fn.getline(2) ~= "" then vim.cmd("normal O") end
    vim.cmd("startinsert")
  end,
})

autocmd({ "BufLeave", "BufWinLeave" }, {
  group = "git_commit",
  pattern = "COMMIT_EDITMSG",
  callback = function() vim.opt.cmdheight = 0 end,
})
