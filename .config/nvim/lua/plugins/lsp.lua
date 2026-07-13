--# selene: allow(mixed_table)

local plugins = {
  -- LSP-based breadcrumb navigation in statusline
  {
    "SmiteshP/nvim-navic",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {
      separator = " >",
      depth_limit = 0,
      depth_limit_indicator = "..",
      safe_output = true,
      click = true,
    },
  },

  -- Package manager for LSP servers, DAP servers, linters, and formatters
  { "williamboman/mason.nvim" },
  -- Automatic color highlighting for LSP diagnostics
  { "folke/lsp-colors.nvim" },
  -- Shows lightbulb icon when LSP code actions are available
  {
    "kosayoda/nvim-lightbulb",
    dependencies = {
      "antoinemadec/FixCursorHold.nvim",
    },
    opts = {
      autocmd = { enabled = true },
      sign = {
        enabled = false,
        priority = 1,
      },
      virtual_text = {
        enabled = true,
      },
    },
  },

  -- {
  --   -- :lua vim.lsp.buf.incoming_calls()
  --   -- :lua vim.lsp.buf.outgoing_calls()
  --   "ldelossa/calltree.nvim",
  --   config = function()
  --     require "calltree".setup {}
  --   end,
  -- },

  -- Asynchronous linting for various file types
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        -- docker = { "hadolint" },
        html = { "tidy" },
        javascript = { "eslint" },
        json = { "jsonlint" },
        markdown = { "markdownlint" },
        rst = { "rstlint" },
        yaml = { "yamllint" },
        zsh = { "zsh" },
      }

      local codespell_args = { "--builtin", "clear,rare,informal,usage,names" }
      local found =
        vim.fs.find(".codespell", { upward = true, path = vim.fn.getcwd() })[1]
      if found then vim.list_extend(codespell_args, { "-I", found }) end
      vim.list_extend(codespell_args, { "--stdin-single-line", "-" })
      lint.linters.codespell.args = codespell_args

      -- perlimports lint (active when perl-lsp is the current server).  Feed
      -- the live buffer on stdin with --read-stdin so it lints on-type like
      -- perlcritic, rather than re-reading the saved file from disk.
      -- --read-stdin needs the filename passed explicitly with -f (it rejects a
      -- bare positional), so append it as a function and stop nvim-lint adding
      -- its own.
      lint.linters.perlimports = {
        cmd = "perlimports",
        args = {
          "--lint",
          "--read-stdin",
          "-f",
          function() return vim.api.nvim_buf_get_name(0) end,
        },
        append_fname = false,
        stdin = true,
        ignore_exitcode = true,
        stream = "stderr",
        parser = function(output)
          local diagnostics = {}
          for line in output:gmatch("[^\n]+") do
            -- Match only a genuine finding, which perlimports prefixes with a
            -- cross mark: "❌ Module (reason) at FILE line N".  Anchoring on the
            -- mark keeps the whole message and the real source line.  Without it
            -- the pattern also matched "Can't locate ... at (eval N) line N"
            -- compile errors, capturing just their trailing "module) (@INC
            -- ...)" fragment against the eval's internal line number.  Those
            -- errors mean perlimports could not load a dependency, which the
            -- Perl language server already reports against the correct paths, so
            -- dropping them here loses no signal.
            local msg, lnum = line:match("^❌%s+(%S+ %b()) at .+ line (%d+)")
            if msg and lnum then
              table.insert(diagnostics, {
                lnum = tonumber(lnum) - 1,
                col = 0,
                message = msg,
                severity = vim.diagnostic.severity.WARN,
                source = "perlimports",
              })
            end
          end
          return diagnostics
        end,
      }

      -- perlcritic lint (active when perl-lsp/EM is the current server).  Runs
      -- real Perl::Critic with the project .perlcriticrc, which EM's native
      -- critic cannot reproduce.  A wrapper reads the buffer from stdin but
      -- reports it under the real filename (--file), so it lints live (unsaved
      -- content) like PerlNavigator while filename policies such as
      -- RequireFilenameMatchesPackage still fire.
      local function perlcriticrc()
        return vim.fs.find(".perlcriticrc", {
          upward = true,
          path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        })[1]
      end

      -- PerlNavigator's default critic severity mapping (perlcritic 1-5).
      local perlcritic_severity = {
        ["5"] = vim.diagnostic.severity.WARN,
        ["4"] = vim.diagnostic.severity.INFO,
        ["3"] = vim.diagnostic.severity.HINT,
        ["2"] = vim.diagnostic.severity.HINT,
        ["1"] = vim.diagnostic.severity.HINT,
      }

      lint.linters.perlcritic = {
        cmd = os.getenv("LINT_PERL_PATH") or "perl",
        stdin = true,
        append_fname = false,
        ignore_exitcode = true,
        stream = "stdout",
        args = {
          vim.fn.stdpath("config") .. "/scripts/perlcritic-stdin.pl",
          "--file",
          function() return vim.api.nvim_buf_get_name(0) end,
          function() return "--profile=" .. (perlcriticrc() or "") end,
        },
        parser = function(output)
          local diagnostics = {}
          for line in output:gmatch("[^\n]+") do
            local lnum, col, sev, policy, msg =
              line:match("^.-:(%d+):(%d+):(%d+):%[([^%]]+)%]%s*(.*)$")
            if lnum then
              table.insert(diagnostics, {
                lnum = tonumber(lnum) - 1,
                col = math.max(tonumber(col) - 1, 0),
                message = msg,
                code = policy,
                source = "perlcritic",
                severity = perlcritic_severity[sev]
                  or vim.diagnostic.severity.WARN,
              })
            end
          end
          return diagnostics
        end,
      }

      -- perl -c syntax check (active when perl-lsp/EM is the current server),
      -- like PerlNavigator.  Reads the buffer from stdin so it checks live
      -- content; stdin lines map 1:1 to buffer lines, and errors report "- line
      -- N".  Include paths come from the same helper as the LSP servers.
      local perl_check_args = { "-c", "-Mwarnings", "-M-warnings=redefine" }
      do
        local ok, local_defs = pcall(require, "local_defs")
        if ok then
          for _, dir in ipairs(local_defs.fn.perl_inc_dirs()) do
            perl_check_args[#perl_check_args + 1] = "-I" .. dir
          end
        end
      end

      -- Compile-time noise that is not an actionable syntax problem, matching
      -- the perlnavigator diagnostic filters.
      local function perl_check_ignored(msg)
        return msg:find("had compilation errors", 1, true)
          or msg:find("BEGIN failed", 1, true)
          or msg:find("CHECK failed", 1, true)
          or msg:find("Useless use of a constant", 1, true)
          or msg:find("set_first_init_and_end", 1, true)
      end

      lint.linters.perl = {
        cmd = os.getenv("LINT_PERL_PATH") or "perl",
        stdin = true,
        append_fname = false,
        ignore_exitcode = true,
        stream = "stderr",
        args = perl_check_args,
        parser = function(output)
          local diagnostics = {}
          for line in output:gmatch("[^\n]+") do
            if not line:match("^%s") then
              local msg, lnum = line:match("^(.-)%s+at %- line (%d+)")
              if msg and lnum and not perl_check_ignored(msg) then
                table.insert(diagnostics, {
                  lnum = tonumber(lnum) - 1,
                  col = 0,
                  message = msg,
                  source = "perl",
                  severity = vim.diagnostic.severity.ERROR,
                })
              end
            end
          end
          return diagnostics
        end,
      }

      -- Run the perl linters wanted under perl_lsp for the current buffer.
      -- perl -c always applies; perlcritic only when a .perlcriticrc is found.
      -- Run from the project root so relative include paths (-Ilib) and the
      -- plenv .perl-version resolve, regardless of Neovim's own cwd.
      local function lint_perl()
        local root = vim.fs.root(0, {
          "Makefile.PL",
          "Build.PL",
          "cpanfile",
          "dist.ini",
          ".perl-version",
          ".git",
        })
        local opts = root and { cwd = root } or nil
        lint.try_lint("perl", opts)
        if perlcriticrc() then lint.try_lint("perlcritic", opts) end
      end

      local last_lint_time = 0
      local cursor_hold_throttle_ms = 1000

      vim.api.nvim_create_autocmd({
        "BufEnter",
        "BufReadPost",
        "BufWritePost",
        "CursorHold",
      }, {
        callback = function(ev)
          local current_time = vim.loop.hrtime() / 1000000 -- Convert to ms
          if ev.event == "CursorHold" then
            if current_time - last_lint_time < cursor_hold_throttle_ms then
              return
            end
            if not vim.bo.modified then return end
          end

          -- require("notify")(string.format("start lint"))
          lint.try_lint()
          if vim.bo.filetype ~= "SidebarNvim" then
            lint.try_lint("codespell")
          end
          if
            vim.bo.filetype == "perl"
            and vim.g.perl_lsp_server == "perl_lsp"
            and vim.fn.filereadable(".perlimports.toml") == 1
          then
            lint.try_lint("perlimports")
          end
          -- Run the perl linters live: on read, write, and on-type via
          -- CursorHold (throttled and only when modified, above).
          if
            vim.bo.filetype == "perl"
            and vim.g.perl_lsp_server == "perl_lsp"
            and (
              ev.event == "BufReadPost"
              or ev.event == "BufWritePost"
              or ev.event == "CursorHold"
            )
          then
            lint_perl()
          end
          last_lint_time = current_time
          -- require("notify")(string.format("end lint"))
        end,
      })

      -- On a Perl LSP switch, refresh the perl linters - clear them (they are
      -- only wanted under perl_lsp, and perlnavigator provides its own), then
      -- re-run when switching to perl_lsp.
      vim.api.nvim_create_autocmd("User", {
        pattern = "PerlLspChanged",
        callback = function()
          if vim.bo.filetype ~= "perl" then return end
          vim.diagnostic.reset(lint.get_namespace("perlcritic"), 0)
          vim.diagnostic.reset(lint.get_namespace("perl"), 0)
          if vim.g.perl_lsp_server == "perl_lsp" then lint_perl() end
        end,
      })

      -- nvim-lint lazy-loads on the perl buffer's BufReadPost, so its autocmd
      -- can miss that first event.  Lint the current buffer now.
      vim.schedule(function()
        if
          vim.bo.filetype == "perl" and vim.g.perl_lsp_server == "perl_lsp"
        then
          lint_perl()
        end
      end)
    end,
  },
  -- Asynchronous linting engine
  {
    "dense-analysis/ale",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      vim.g.ale_linters_explicit = 0
      vim.g.ale_disable_lsp = "auto"
      vim.g.ale_use_neovim_diagnostics_api = 1
      vim.g.ale_virtualtext_cursor = 0
      vim.g.ale_linters = {
        -- go = { "gofmt", "golint", "gopls", "govet", "golangci-lint" },
        go = {},
        html = {},
        lua = {},
        markdown = {},
        perl = {},
        sh = {},
        yaml = { "spectral" },
      }
      vim.g.ale_pattern_options = {
        ["gitlab-ci"] = { ale_linters = { yaml = {} } },
      }
      -- vim.g.ale_fixers = {
      -- }
    end,
  },
  -- Code formatting with support for multiple formatters per filetype
  {
    "stevearc/conform.nvim",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local codespell_args = {
        "$FILENAME",
        "--write-changes",
        "--check-hidden", -- conform's temp file is hidden
        "--builtin",
        "clear,rare,informal,usage,names",
      }
      local found =
        vim.fs.find(".codespell", { upward = true, path = vim.fn.getcwd() })[1]
      if found then vim.list_extend(codespell_args, { "-I", found }) end

      require("conform").setup({
        formatters_by_ft = {
          dockerfile = { "dockerfmt" },
          javascript = { "prettierd", "prettier", stop_after_first = true },
          json = { "fixjson" },
          lua = { "stylua", lsp_format = "fallback" },
          make = { "bake" },
          markdown = { "markdownlint", "mdformat", "injected" },
          perl = { "quotefix", lsp_format = "last" },
          python = { "isort", "black" },
          sh = { "shellcheck", "shfmt" },
          bash = { "shellcheck", "shfmt" },
          zsh = { "shellcheck" },
          sql = { "sql_formatter" },
          terraform = { "terraform_fmt" },
          perl = { "perlimports_tidy" },
          yaml = { "yamlfmt" }, -- yamlfix is too buggy
          ["*"] = { "codespell", "typos" },
        },
        formatters = {
          bake = {
            command = "mbake",
          },
          codespell = {
            args = codespell_args,
          },
          mdformat = {
            args = { "--number", "--wrap", "80", "-" },
          },
          quotefix = {
            command = "perl-quote-fix",
            stdin = true,
            range_args = function(_, ctx)
              return {
                "--lines",
                ctx.range.start[1] .. "-" .. ctx.range["end"][1],
              }
            end,
            condition = function()
              return vim.fn.executable("perl-quote-fix") == 1
            end,
          },
          shellcheck = {
            args = { "--shell=bash", "-" },
          },
          dockerfmt = {
            append_args = { "-i", "2" },
          },
          shfmt = {
            append_args = { "-i", "2" },
          },
          perlimports_tidy = {
            command = "perlimports",
            args = { "--read-stdin", "--filename", "$FILENAME" },
            stdin = true,
            condition = function()
              return vim.g.perl_lsp_server == "perl_lsp"
                and vim.fn.filereadable(".perlimports.toml") == 1
            end,
          },
          injected = {
            options = {
              lang_to_formatters = {
                sql = {},
                yaml = {},
              },
            },
          },
        },
        default_format_opts = {
          lsp_format = "first",
        },
        log_level = vim.log.levels.DEBUG,
      })
    end,
  },
  -- Rule-based linting and code analysis
  { "chrisgrieser/nvim-rulebook" },

  -- Automatic ctags generation and management
  {
    "ludovicchabant/vim-gutentags",
    config = function()
      vim.g.gutentags_ctags_exclude =
        require("local_defs").fn.gutentags_ctags_exclude()
      -- print(vim.inspect(vim.g.gutentags_ctags_exclude))

      -- can be extended with '*/sub/path' if required
      vim.g.gutentags_generate_on_new = 1
      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_generate_on_empty_buffer = 0

      local is_freebsd = vim.uv.os_uname().sysname == "FreeBSD"
      if is_freebsd then
        vim.g.gutentags_ctags_executable = "/usr/local/bin/uctags"
      end
    end,
  },
}

return plugins
