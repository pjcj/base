" Automatically generated packer.nvim plugin loader code

if !has('nvim-0.5')
  echohl WarningMsg
  echom "Invalid Neovim version for packer.nvim!"
  echohl None
  finish
endif

packadd packer.nvim

try

lua << END
  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/pjcj/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/pjcj/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/pjcj/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/pjcj/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/pjcj/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ale = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/ale"
  },
  ["compe-tmux"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/compe-tmux"
  },
  ["crazy8.nvim"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/crazy8.nvim"
  },
  ["git-messenger.vim"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/git-messenger.vim"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/gitsigns.nvim"
  },
  ["indent-blankline.nvim"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/lualine.nvim"
  },
  ["neovim-colors-solarized-truecolor-only"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/neovim-colors-solarized-truecolor-only"
  },
  ["nvim-colorizer.lua"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua"
  },
  ["nvim-comment"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/nvim-comment"
  },
  ["nvim-compe"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/nvim-compe"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-lspinstall"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/nvim-lspinstall"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["vim-autoswap"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/vim-autoswap"
  },
  ["vim-easy-align"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/vim-easy-align"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-gh-line"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/vim-gh-line"
  },
  ["vim-go"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/vim-go"
  },
  ["vim-interestingwords"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/vim-interestingwords"
  },
  ["vim-lastplace"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/vim-lastplace"
  },
  ["vim-smoothie"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/vim-smoothie"
  },
  ["vim-startify"] = {
    loaded = true,
    path = "/Users/pjcj/.local/share/nvim/site/pack/packer/start/vim-startify"
  }
}

time([[Defining packer_plugins]], false)
if should_profile then save_profiles() end

END

catch
  echohl ErrorMsg
  echom "Error in packer_compiled: " .. v:exception
  echom "Please check your config for correctness"
  echohl None
endtry
