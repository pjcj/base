local local_defs = {
  map = {
    defmap = { noremap = true, silent = true }, -- default map options,
  },
  -- Shared, dependency-free palette so the same colours are used outside
  -- Neovim too (e.g. the Hammerspoon which-key panel).
  colour = require("solarized_palette"),
  fn = {},
}

local function set_exclude()
  local ex = vim.g.gutentags_ctags_exclude or {}
  local fd = { "fd", "--type", "f", "--color", "never" }
  local ignore_patterns = { "*.git/*", "term://*" }
  local exclude = {
    "tmp",
    "blib",
    "node_modules",
    "dist",
  }

  local excl = os.getenv("EXCLUDE_PATHS")
  if excl then
    for path in string.gmatch(excl, "([^:]+)") do
      table.insert(exclude, path)
    end
  end

  for _, v in pairs(exclude) do
    table.insert(ex, v)
    table.insert(fd, "-E")
    table.insert(fd, v)
    table.insert(ignore_patterns, "*/" .. v .. "/*")
  end

  local_defs.gutentags_ctags_exclude = ex
  local_defs.common_fd = fd
  local_defs.frecency_ignore_patterns = ignore_patterns
end

local_defs.fn.gutentags_ctags_exclude = function()
  set_exclude()
  return local_defs.gutentags_ctags_exclude
end

local_defs.fn.common_fd = function()
  set_exclude()
  -- print(vim.inspect(local_defs.common_fd))
  return local_defs.common_fd
end

local_defs.fn.frecency_ignore_patterns = function()
  set_exclude()
  return local_defs.frecency_ignore_patterns
end

local_defs.fn.perl_inc_dirs = function()
  local function split_env_var(env_var, delimiter)
    local parts = {}
    for part in string.gmatch(env_var, "[^" .. delimiter .. "]+") do
      table.insert(parts, part)
    end
    return parts
  end

  -- Print environment variables for perlnavigator before use
  -- print("LINT_PERL_PATH:", os.getenv("LINT_PERL_PATH"))
  -- print("LINT_PERL_PATHS (raw from env):", os.getenv("LINT_PERL_PATHS"))

  -- Define default include paths
  local default_include_paths = { "lib", "local/lib/perl5", "t/lib" }

  -- Get paths from environment variable
  local env_paths_str = os.getenv("LINT_PERL_PATHS") or ""
  local env_specific_paths = split_env_var(env_paths_str, ":")

  -- Combine paths: environment paths first, then default paths
  local final_include_paths = {}
  -- Add paths from the environment variable first
  for _, path in ipairs(env_specific_paths) do
    table.insert(final_include_paths, path)
  end
  -- Then, append default paths
  for _, path in ipairs(default_include_paths) do
    table.insert(final_include_paths, path)
  end

  -- Print the final calculated includePaths
  -- print(
  --   "Final includePaths for perlnavigator:",
  --   vim.inspect(final_include_paths)
  -- )

  return final_include_paths
end

local_defs.fn.large_perl_file = function(bufnr)
  bufnr = bufnr or 0
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if filetype ~= "perl" then return false end
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  return line_count > 5000
end

local wk = require("which-key")
-- local wk -- swap these to bootstrap

local_defs.fn.set_buffer_settings = function()
  local ft = vim.bo.filetype
  local b = vim.b -- a table to access buffer variables
  local lopt = vim.opt_local -- set local options

  -- https://github.com/stsewd/tree-sitter-comment/issues/22
  vim.api.nvim_set_hl(0, "@lsp.type.comment", {})

  if ft == "go" or ft == "gomod" or ft == "make" then
    local current_listchars = vim.opt.listchars:get()
    current_listchars.tab = "  "
    lopt.listchars = current_listchars

    local e = b.editorconfig
    if e == nil or e.indent_style == nil then lopt.expandtab = false end
    if e == nil or e.indent_size == nil then
      lopt.tabstop = 2
      lopt.shiftwidth = 2
    end

    if ft == "go" then
      wk.register({
        ["<leader>"] = {
          ["o"] = {
            name = "+go",
            a = { ":GoAlt<cr>", "alt" },
            c = { ":GoCmt<cr>", "comment" },
            e = { ":GoIfErr<cr>", "iferr" },
            f = { ":GoFmt<cr>", "fmt" },
            F = { ":GoFmt -a<cr>", "fmt all" },
            l = { ":GoLint<cr>", "lint" },
            n = { ":GoRename<cr>", "rename" },
            g = {
              name = "+tag",
              a = { ":GoAddTag<cr>", "add" },
              c = { ":GoClearg<cr>", "clear" },
              r = { ":GoRmTag<cr>", "remove" },
            },
          },
        },
      }, { buffer = 0, mode = "n" })
    end
    return
  end

  local current_listchars = vim.opt.listchars:get()
  current_listchars.tab = "» "
  lopt.listchars = current_listchars
  lopt.tabstop = 8
  lopt.expandtab = true

  if ft == "gitcommit" then
    lopt.colorcolumn = { 50, 72 }
    lopt.textwidth = 72
    lopt.spell = true
    lopt.spelllang = "en_gb"
  end

  if ft == "helm" then vim.diagnostic.enable(false) end
end

return local_defs
