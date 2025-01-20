local wezterm = require('wezterm')

local M = {}


function M.is_array(a)
  -- rely on #a == 0  and next returning non-nil for table objects
  -- assume {} is an array
  return type(a) == 'table' and (#a > 0 or next(a) == nil)
end

function M.mk_transparent(c)
  if c ~= nil then
    if type(c) == 'string' then
      c = wezterm.color.parse(c)
    end
    local h, s, l, a = c:hsla()
    return wezterm.color.from_hsla(h, s, l, 0.0)
  end
end

function M.deep_extend(t1, t2)
  local overwrite = {
    status_left = true,
    status_right = true,
    tab_active = true,
    tab_inactive = true,
  }

  local function merge(a, b)
    if type(a) ~= 'table' or type(b) ~= 'table' then
      return b
    end
    for k, v in pairs(b) do
      if overwrite[k] then
        a[k] = M.deep_copy(v)
      elseif type(v) == 'table' then
        local va = a[k]
        if va == nil or type(va) ~= 'table' then
          va = {}
        end
        a[k] = merge(va, M.deep_copy(v))
      else
        a[k] = v
      end
    end
    return a
  end

  return merge(t1, t2)
end

function M.deep_copy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[M.deep_copy(orig_key)] = M.deep_copy(orig_value)
    end
    setmetatable(copy, M.deep_copy(getmetatable(orig)))
  else
    copy = orig
  end
  return copy
end

function M.insert_elements(dest, src)
  for _, v in ipairs(src) do
    table.insert(dest, v)
  end
end

local reset_attributes = {
  { Attribute = { Underline = 'None' } },
  { Attribute = { Intensity = 'Normal' } },
  { Attribute = { Italic = false } },
}

local function require_component(object, v)
  local component
  if object.tab_id then
    component = 'tabline.components.tab.' .. v
  else
    component = 'tabline.components.window.' .. v
  end
  return component
end

function M.extract_components(components_opts, attributes, object, format)
  local component_opts = require('tabline.config').component_opts
  local components = {}
  for _, v in ipairs(components_opts) do
    if type(v) == 'string' then
      if v == 'ResetAttributes' then
        M.insert_elements(components, reset_attributes)
        M.insert_elements(components, attributes)
      else
        local ok, result = pcall(require, require_component(object, v))
        if ok then
          local opts = M.deep_copy(component_opts)
          if result.default_opts then
            opts = M.deep_extend(result.default_opts, opts)
          end
          local component = M.create_component(result.update(object, opts), opts, object, attributes, format)
          if component then
            M.insert_elements(components, component)
          end
        else
          table.insert(components, { Text = v .. '' })
        end
      end
    elseif type(v) == 'table' and type(v[1]) == 'string' then
      local ok, result = pcall(require, require_component(object, v[1]))
      if ok then
        local opts = M.deep_copy(component_opts)
        if result.default_opts then
          opts = M.deep_extend(result.default_opts, opts)
        end
        opts = M.deep_extend(opts, v)
        table.remove(opts, 1)
        local component = M.create_component(result.update(object, opts), opts, object, attributes, format)
        if component then
          M.insert_elements(components, component)
        end
      end
    elseif type(v) == 'function' then
      table.insert(components, { Text = v(object) .. '' })
    elseif type(v) == 'table' then
      table.insert(components, v)
    end
  end
  return components
end

function M.create_component(name, opts, object, attributes, format)
  if name == nil then
    return
  end
  if opts.cond and not opts.cond(object) then
    return
  end
  if opts.fmt then
    name = opts.fmt(name, object)
  end
  if opts.icon and opts.icons_only then
    name = ''
  end

  local result
  local left_padding_element, right_padding_element
  local left_padding, right_padding
  if opts.padding then
    if type(opts.padding) == 'table' then
      left_padding = string.rep(' ', opts.padding.left or 0)
      right_padding = string.rep(' ', opts.padding.right or 0)
    else
      left_padding = string.rep(' ', opts.padding)
      right_padding = left_padding
    end
    left_padding_element = { Text = left_padding }
    right_padding_element = { Text = right_padding }
  end
  if opts.icons_enabled and opts.icon then
    local icon_name = {}
    table.insert(icon_name, left_padding_element)
    if type(opts.icon) == 'table' then
      if opts.icon.align == 'right' then
        table.insert(icon_name, { Text = name })
        if opts.icon.color then
          if opts.icon.color.fg then
            table.insert(icon_name, { Foreground = { Color = opts.icon.color.fg } })
          end
          if opts.icon.color.bg then
            table.insert(icon_name, { Background = { Color = opts.icon.color.bg } })
          end
        end
        table.insert(icon_name, { Text = ' ' .. opts.icon[1] })
        M.insert_elements(icon_name, reset_attributes)
        M.insert_elements(icon_name, attributes)
      else
        if opts.icon.color then
          if opts.icon.color.fg then
            table.insert(icon_name, { Foreground = { Color = opts.icon.color.fg } })
          end
          if opts.icon.color.bg then
            table.insert(icon_name, { Background = { Color = opts.icon.color.bg } })
          end
        end
        table.insert(icon_name, { Text = opts.icon[1] .. ' ' })
        M.insert_elements(icon_name, reset_attributes)
        M.insert_elements(icon_name, attributes)
        table.insert(icon_name, { Text = name })
      end
    else
      table.insert(icon_name, { Text = opts.icon .. ' ' })
      table.insert(icon_name, { Text = name })
    end
    table.insert(icon_name, right_padding_element)
    result = icon_name
    if format then
      result = { { Text = wezterm.format(icon_name) } }
    end
  else
    result = { { Text = left_padding .. name .. right_padding } }
  end
  return result
end

function M.overwrite_icon(opts, new_icon)
  if type(new_icon) == 'table' and type(opts.icon) == 'table' then
    opts.icon[1] = M.deep_copy(new_icon[1])
  else
    opts.icon = M.deep_copy(new_icon)
  end
end

return M
