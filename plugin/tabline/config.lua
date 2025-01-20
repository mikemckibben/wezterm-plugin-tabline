local wezterm = require('wezterm')
local util = require('tabline.util')

local M = {}

local default_opts = {
  options = {
    theme = 'Tokyo Night',
    tabs_enabled = true,
    section_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
  },
  sections = {
    status_left = { 'workspace' },
    tab_active = {'index', { 'process', padding = { left = 0, right = 1 } } },
    tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },
    status_right = { 'domain' },
  },
}

local default_component_opts = {
  icons_enabled = true,
  icons_only = false,
  padding = 1,
}

local function get_color_scheme(theme)
  local default_colors = wezterm.color.get_default_colors()
  if type(theme) ~= 'string' then
    -- assume a valid color scheme config
    return util.deep_extend(default_colors, theme)
  end

  local scheme = wezterm.color.get_builtin_schemes()[theme]
  if scheme ~= nil then
    return scheme
  end
  -- fallback to default color scheme
  return default_colors
end

local function get_theme(theme)
  local colors = get_color_scheme(theme)
  return {
    status_left = {
      fg = colors.background,
      bg = colors.ansi[5]
    },
    status_right = {
      fg = colors.background,
      bg = colors.ansi[5]
    },
    colors = colors
  }
end

local function set_component_opts(user_opts)
  local component_opts = {}

  for key, default_value in pairs(default_component_opts) do
    component_opts[key] = default_value
    if user_opts.options[key] ~= nil then
      component_opts[key] = user_opts.options[key]
      user_opts.options[key] = nil
    end
  end

  return component_opts
end

function M.set(user_opts)
  user_opts = user_opts or { options = {} }
  user_opts.options = user_opts.options or {}
  local theme_overrides = user_opts.options.theme_overrides or {}
  user_opts.options.theme_overrides = nil

  M.component_opts = set_component_opts(user_opts)
  M.opts = util.deep_extend(util.deep_copy(default_opts), user_opts)
  M.sections = util.deep_copy(M.opts.sections)
  M.theme = util.deep_extend(get_theme(M.opts.options.theme), theme_overrides)
end

return M
