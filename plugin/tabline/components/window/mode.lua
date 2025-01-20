local M = {}

function M.update(window)
  local mode = M.get(window)
  mode = mode:upper()
  return mode
end

function M.get(window)
  local key_table = window:active_key_table()

  if key_table == nil then
    key_table = 'normal'
  end

  return key_table
end

return M
