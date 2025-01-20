--local modulepath = select('1', ...):match(".+%.") or ""
local modulepath = ...
local wezterm = require('wezterm')

--- Checks if the user is on windows
local is_windows = string.match(wezterm.target_triple, 'windows') ~= nil
local separator = is_windows and '\\' or '/'

local function resolve_plugin_path()
  for _, plugin in ipairs(wezterm.plugin.list()) do
    if plugin.component == modulepath then
      return plugin.plugin_dir
    end
  end
end

local plugin_path = resolve_plugin_path()
if not plugin_path then
   wezterm.log_error("unable to resolve plugin dir for " .. modulepath)
   return
end

package.path = package.path .. ";" .. plugin_path .. separator .. "plugin" .. separator .. "?.lua"

local M = {}

function M.setup(opts)
  require('tabline.config').set(opts)

  wezterm.on('update-status', function(window)
    require('tabline.component').set_status(window)
  end)

  wezterm.on('format-tab-title', function(tab, _, _, _, hover, _)
    return require('tabline.tabs').set_title(tab, hover)
  end)
end

function M.apply_to_config(config)
  local theme = require('tabline.config').theme
  config.use_fancy_tab_bar = true
  --config.show_close_tab_button_in_tabs = true
  config.tab_max_width = 35
  config.window_decorations = 'RESIZE'
  config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }
  config.window_frame = {
    font = config.font,
    font_size = 10,
    active_titlebar_bg = theme.colors.background,
    inactive_titlebar_bg = theme.colors.background
  }
  config.colors = theme.colors
  config.status_update_interval = 500
end

function M.get_config()
  return require('tabline.config').opts
end

function M.get_colors()
  return require('tabline.config').colors
end

function M.refresh(window, tab)
  if window then
    require('tabline.component').set_status(window)
  end
  if tab then
    require('tabline.tabs').set_title(tab)
  end
end

return M
