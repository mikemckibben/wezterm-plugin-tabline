local wezterm = require('wezterm')
local util = require('tabline.util')
local config = require('tabline.config')
local M = {}

local function create_attributes(window)
  local theme = config.theme
  local left = {
    { Foreground = { Color = theme.status_left.fg or theme.colors.foreground } },
    { Background = { Color = theme.status_left.bg or theme.colors.background } },
    { Attribute = { Intensity = 'Bold' } },
  }
  local right = {
    { Foreground = { Color = theme.status_right.fg or theme.colors.foreground } },
    { Background = { Color = theme.status_right.bg or theme.colors.background } },
    { Attribute = { Intensity = 'Bold' } },
  }
  return left, right
end

local function get_separator(is_left)
  local sep = nil
  if type(config.opts.options.component_separators) == 'table' then
    if is_left then
      sep = config.opts.options.component_separators['left']
    else
      sep = config.opts.options.component_separators['right']
    end
  end
  if sep == nil then
    sep = config.opts.options.component_separators
  end
  return sep
end

local function insert_component_separators(components, is_left)
  local sep = get_separator(is_left)
  local i = 1

  if sep == nil then
    return components
  end
  while i <= #components do
    if type(components[i]) == 'table' and components[i].Text and i < #components then
      i = i + 1
      table.insert(components, i, { Text = sep })
    end
    i = i + 1
  end
  return components
end

local function create_section(components, attributes)
  local result = {}
  if #components > 0 then
    util.insert_elements(result, attributes)
    util.insert_elements(result, components)
  end
  return result
end

local function create_sections(window)
  local sections = config.sections
  left_attributes, right_attributes = create_attributes(window)
  left_components = insert_component_separators(util.extract_components(sections.status_left, left_attributes, window, true), true)
  right_components = insert_component_separators(util.extract_components(sections.status_right, right_attributes, window, true), false)
  status_left = create_section(left_components, left_attributes)
  status_right = create_section(right_components, right_attributes)
  return status_left, status_right
end


function M.set_status(window)
  local left_status, right_status = create_sections(window)
  -- print('left: ' .. wezterm.json_encode(left_status))
  -- print('right: ' .. wezterm.json_encode(right_status))
  if #left_status > 0 then
    window:set_left_status(wezterm.format(left_status))
  else
    window:set_left_status('')
  end
  if #right_status > 0 then
    window:set_right_status(wezterm.format(right_status))
  else
    window:set_right_status('')
  end
end

return M
