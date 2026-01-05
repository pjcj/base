local local_defs = {
  map = {
    defmap = { noremap = true, silent = true }, -- default map options,
  },
  colour = {
    -- stylua: ignore start
    base03      = "#001920",
    base02      = "#022731",
    base01      = "#586e75",
    base00      = "#657b83",
    base0       = "#839496",
    base1       = "#93a1a1",
    base2       = "#eee8d5",
    base3       = "#fdf6e3",
    yellow      = "#b58900",
    orange      = "#cb4b16",
    red         = "#dc322f",
    magenta     = "#d33682",
    violet      = "#6c71c4",
    blue        = "#268bd2",
    cyan        = "#2aa198",
    green       = "#859900",
    normal      = "#9599dc",

    base04      = "#00090c", -- darker than base03
    base05      = "#0e3c49", -- lighter than base02
    base06      = "#012028", -- lighter than base03
    peach       = "#ffdc79", -- peach
    pyellow     = "#fff179", -- pale yellow
    llyellow    = "#f0a63f", -- light yellow
    lyellow     = "#de860e", -- light yellow
    dyellow     = "#433200", -- dark yellow
    dorange     = "#7d2500", -- dark orange
    lllred      = "#ffacaa", -- light light light red
    llred       = "#ff8784", -- light light red
    lred        = "#f05a5c", -- light red
    mred        = "#64110f", -- medium red
    lmred       = "#d37b79", -- light medium red
    dred        = "#400200", -- dark red
    ddred       = "#2b0200", -- dark dark red
    dddred      = "#150100", -- dark dark dark red
    lviolet     = "#c0c3ef", -- light violet
    mviolet     = "#7c81e4", -- medium violet
    dviolet     = "#323799", -- dark violet
    ddviolet    = "#0F1363", -- dark dark violet
    dcyan       = "#04746c", -- dark cyan
    llblue      = "#9fcff2", -- light light blue
    lblue       = "#73b5e4", -- light blue
    dblue       = "#06568f", -- dark blue
    ddblue      = "#023458", -- dark dark blue
    lllgreen    = "#c9f5cc", -- light light light green
    llgreen     = "#98e59d", -- light light green
    lgreen      = "#6dd374", -- light green
    rgreen      = "#25ad2e", -- a nice green for diffs (opposite of red)
    dgreen      = "#017008", -- dark green
    ddgreen     = "#003203", -- dark dark green

    c_rosewater = "#ffacaa",
    c_flamingo  = "#ff8784",
    c_pink      = "#ffc67b",
    c_mauve     = "#6c71c4",
    c_red       = "#fe9569",
    c_maroon    = "#9599dc",
    c_peach     = "#ffdc79",
    c_yellow    = "#fff179",
    c_green     = "#6dd374",
    c_teal      = "#a9eae5",
    c_sky       = "#78d3cc",
    c_sapphire  = "#9fcff2",
    c_blue      = "#73b5e4",
    c_lavender  = "#c0c3ef",
    c_text      = "#fdf6e3",
    c_subtext1  = "#eee8d5",
    c_subtext0  = "#93a1a1",
    c_overlay2  = "#839496",
    c_overlay1  = "#657b83",
    c_overlay0  = "#586e75",
    c_surface2  = "#0e3c49",
    c_surface1  = "#022731",
    c_surface0  = "#012028",
    c_base      = "#001920",
    c_mantle    = "#00090c",
    c_crust     = "#000000",
    -- stylua: ignore end

    -- grey order
    -- base04 = "#00090c",
    -- base03 = "#001920",
    -- base06 = "#012028",
    -- base02 = "#022731",
    -- base05 = "#0e3c49",
    -- base01 = "#586e75",
    -- base00 = "#657b83",
    -- base0  = "#839496",
    -- base1  = "#93a1a1",
    -- base2  = "#eee8d5",
    -- base3  = "#fdf6e3",

    none = "none",
    reverse = "reverse",
    underline = "underline",
  },
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
