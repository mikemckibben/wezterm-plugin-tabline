local cwd = ''

return {
  default_opts = { max_length = 25 },
  update = function(window, opts)
    local cwd_uri = window:active_pane():get_current_working_dir()
    if cwd_uri then
      local cwd = cwd_uri.file_path
      if #cwd > opts.max_length then
        cwd = '…' .. cwd:sub(-1 * opts.max_length)
      end
      return cwd
    end
    return nil
  end,
}
