local cwd = ''

return {
  default_opts = { max_length = 10 },
  update = function(tab, opts)
    local cwd_uri = tab.active_pane.current_working_dir
    if cwd_uri then
      local cwd = cwd_uri.file_path
      if cwd and #cwd > opts.max_length then
        cwd = '…' .. cwd:sub(-1*opts.max_length)
      end
      return cwd
    end
    return ''
  end,
}
