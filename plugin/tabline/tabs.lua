local wezterm = require('wezterm')
local config = require('tabline.config')
local util = require('tabline.util')

local M = {}

local active_attributes, inactive_attributes, active_separator_attributes, inactive_separator_attributes =
  {}, {}, {}, {}
local tab_active, tab_inactive = {}, {}

local function create_attributes(hover)
  local colors = config.theme.colors.tab_bar

  active_attributes = {
    { Foreground = { Color = colors.active_tab.fg_color } },
    { Background = { Color = colors.active_tab.bg_color } },
  }
  inactive_attributes = {
    { Foreground = { Color = hover and colors.inactive_tab_hover.fg_color or colors.inactive_tab.fg_color } },
    { Background = { Color = hover and colors.inactive_tab_hover.bg_color or colors.inactive_tab.bg_color } },
  }
  active_separator_attributes = {
    { Foreground = { Color = colors.active_tab.bg_color } },
    { Background = { Color = colors.active_tab.fg_color } },
  }
  inactive_separator_attributes = {
    { Foreground = { Color = hover and colors.inactive_tab_hover.bg_color or colors.inactive_tab.bg_color } },
    { Background = { Color = colors.inactive_tab.bg_color } },
  }
end

local function create_tab_content(tab)
  local sections = config.sections
  tab_active = util.extract_components(sections.tab_active, active_attributes, tab)
  tab_inactive = util.extract_components(sections.tab_inactive, inactive_attributes, tab)
end

local function tabs(tab)
  local result = {}

  if #tab_active > 0 and tab.is_active then
    util.insert_elements(result, active_attributes)
    util.insert_elements(result, tab_active)
  elseif #tab_inactive > 0 then
    util.insert_elements(result, inactive_attributes)
    util.insert_elements(result, tab_inactive)
  end
  return result
end

M.set_title = function(tab, hover)
  if not config.opts.options.tabs_enabled then
    return
  end
  create_attributes(hover)
  create_tab_content(tab)
  return tabs(tab)
end

return M
