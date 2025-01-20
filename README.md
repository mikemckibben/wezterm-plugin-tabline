# wezterm-plugin-tabline

This is a fork of [tabline.wez](https://github.com/michaelbrusegard/tabline.wez).

A versatile and easy to use tab-bar written in Lua.

`wezterm-plugin-tabline` requires the [WezTerm](https://wezfurlong.org/wezterm/index.html) terminal emulator.

Tabline was greatly inspired by [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim/tree/master), a statusline plugin for [Neovim](https://neovim.io), and tries to use the same configuration format.

## Screenshots

Here is a preview of what the tab-bar can look like.

<p>
</p>

`wezterm-plugin-tabline` supports all the same themes as WezTerm. You can find the list of themes [here](https://wezfurlong.org/wezterm/colorschemes/index.html).

## Installation

### WezTerm Plugin API

```lua
local tabline = wezterm.plugin.require("https://github.com/mikemckibben/wezterm-plugin-tabline")
```

You'll also need to have a patched font if you want icons.

## Usage and customization

Tabline has sections as shown below just like lualine with the addition of `tabs` in the middle.

```text
+-------------------------------------------------+
| LEFT |  TABS                            | RIGHT |
+-------------------------------------------------+
```

Each sections holds its components.

### Configuring tabline in wezterm.lua

#### Default configuration

```lua
tabline.setup({
  options = {
    icons_enabled = true,
    theme = 'Catppuccin Mocha',
    tabs_enabled = true,
    theme_overrides = {},
    component_separators = {
      left = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
  },
  sections = {
    status_left = { 'workspace',  },
    tab_active = {
      'index',
      { 'cwd', padding = { left = 0, right = 1 } },
      { 'zoomed', padding = 0 },
    },
    tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },
    status_right = { 'ram', 'cpu', 'datetime', 'battery', 'domain' },
  },
})
```

If you want to get your current tabline config, you can
do so with:

```lua
tabline.get_config()

```

#### WezTerm configuration

Tabline requires that some options are applied to the WezTerm
[Config](https://wezfurlong.org/wezterm/config/lua/config/index.html) struct.
For example the retro tab-bar must be enabled. Tabline provides a function to
apply some recommended options to the config. If you already set these options
in your `wezterm.lua` you do not need this function. This needs to be called
after `wezterm.setup()`.

```lua
tabline.apply_to_config(config)
```

> [!CAUTION]
> This function has nothing to do with the tabline config passed into setup and
> retrieved with `tabline.get_config()`. It only applies some recommended
> options to the WezTerm config. More info
> [here](https://github.com/michaelbrusegard/tabline.wez/discussions/3)

---

### Starting tabline

```lua
tabline.setup()
```

---

### Setting a theme

```lua
options = { theme = 'GruvboxDark' }
```

All available themes are found
[here](https://wezfurlong.org/wezterm/colorschemes/index.html). Tabline uses
[get_builtin_schemes()](https://wezfurlong.org/wezterm/config/lua/wezterm.color/get_builtin_schemes.html)
under the hood. To get around this it is also possible to input your own colors
from the WezTerm config or a completely custom colors scheme object.

```lua
options = { theme = config.colors } -- This is the WezTerm config colors object
```

#### Customizing themes

To modify a theme, you can use the `theme_overrides` option.

```lua
-- Change the background of status_left section
tabline.setup({
  options = {
    theme_overrides = {
      status_left = {
        bg = '#112233',
      },
    }
  }
})
```

This is also where you would specify the colors for a new [Key
Table](https://wezfurlong.org/wezterm/config/key-tables.html). 
```lua
tabline.setup({
  options = {
    theme_overrides = {
      key_tables = {
        -- key corresponds to key under wezterm config.key_tables
        my_key_table = { bg = '#313244' },
        -- ...
      }
      -- Default tab colors
      tab = {
        active = { fg = '#89b4fa', bg = '#313244' },
        inactive = { fg = '#cdd6f4', bg = '#181825' },
        inactive_hover = { fg = '#f5c2e7', bg = '#313244' },
      }
    }
  }
})
```

#### Getting theme

If you want to get the current theme and its colors, you can do so with:

```lua
tabline.get_theme()
```

You will get an object like the `theme_overrides` object above, but with the
addition of a colors property (the colors property is the colors object from the
WezTerm config with every color found there).

---

### Tabs

You can disable overwriting tabs by setting `tabs_enabled` to `false` in the
options table.

---

### Separators

tabline defines three kinds of separators:

- `section_separators` - separators between sections
- `component_separators` - separators between the different components in sections
- `tab_separators` - separators around tabs

```lua
options = {
  section_separators = {
    left = wezterm.nerdfonts.pl_left_hard_divider,
    right = wezterm.nerdfonts.pl_right_hard_divider,
  },
  component_separators = {
    left = wezterm.nerdfonts.pl_left_soft_divider,
    right = wezterm.nerdfonts.pl_right_soft_divider,
  },
  tab_separators = {
    left = wezterm.nerdfonts.pl_left_hard_divider,
    right = wezterm.nerdfonts.pl_right_hard_divider,
  },
}
```

Here, left refers to the left-most sections (a, b, c), and right refers to the
right-most sections (x, y, z). For the tabs it refers to each side of the tab.

#### Disabling separators

```lua
options = {
  section_separators = '',
  component_separators = '',
  tab_separators = '',
}
```

---

### Changing components in tabline sections

```lua
sections = { status_left = { 'mode' } }
```

#### Available components

Tabline separates components into ones available for the tabline components
(`status_left`, `status_right`, etc...), which are grouped under Window since they
have access to the
[Window](https://wezfurlong.org/wezterm/config/lua/window/index.html) object.

And the `tab_active` and `tab_inactive` components which are grouped under Tab
and have access to
[TabInformation](https://wezfurlong.org/wezterm/config/lua/TabInformation.html).

- Window
  - `mode` (current keytable)
  - `battery` (battery percentage)
  - `cpu` (cpu percentage)
  - `datetime` (current date and time)
  - `domain` (current domain)
  - `hostname` (hostname of the machine)
  - `ram` (ram used in GB)
  - `window` (window title)
  - `workspace` (active wezterm workspace)
- Tab
  - `tab` (tab title)
  - `cwd` (current working directory)
  - `output` (indicator if tab has unseen output)
  - `parent` (parent directory)
  - `process` (process name)
  - `index` (tab index)
  - `zoomed` (indicator if tab has zoomed pane)

#### Custom components

##### Lua functions as tabline component

```lua
local function hello()
  return 'Hello World'
end
sections = { status_left = { hello } }
```

> [!NOTE]
> Functions receive the `Window` object or `TabInformation` object as the first
> argument depending on the component group

##### Text string as tabline component

```lua
sections = { status_left = { 'Hello World' } }
```

##### WezTerm Formatitem as tabline component

You can find all the available format items
[here](https://wezfurlong.org/wezterm/config/lua/wezterm/format.html). The
`ResetAttributes` format item has been overwritten to reset all attributes back
to the default for that component instead of the WezTerm default.

```lua
sections = {
  status_left = {
    { Attribute = { Underline = 'Single' } },
    { Foreground = { AnsiColor = 'Fuchsia' } },
    { Background = { Color = 'blue' } },
    'Hello World', -- { Text = 'Hello World' }
  }
}

```

> [!TIP]
> Strings are automatically wrapped in a Text FormatItem when used as a component.

##### Lua expressions as tabline component

You can use any valid lua expression as a component including:

- oneliners
- global variables (as strings)
- require statements

```lua
sections = { status_right = { os.date('%a'), data, require('util').status() } }
```

`data` is a global variable in this example.

---

### Component options

Component options can change the way a component behave.
There are two kinds of options:

- global options affecting all components
- local options affecting specific

Global options can be used as local options (can be applied to specific components)
but you cannot use local options as global.
Global options used locally overwrites the global, for example:

```lua
tabline.setup {
  options = { fmt = string.lower },
  sections = {
    status_left = {
      { 'cwd', fmt = function(str) return str:sub(-20) end }
      'window'
    },
  }
}
```

`cwd` will be formatted with the passed function so last 20 char will be shown.
On the other hand `window` will be formatted with the global formatter
`string.lower` so it will be showed in lower case.

#### Available options

#### Global options

These are `options` that are used in the options table.
They set behavior of tabline.

Values set here are treated as default for other options
that work in the component level.

For example even though `icons_enabled` is a general component option.
You can set `icons_enabled` to `false` and icons will be disabled on all
component. You can still overwrite defaults set in the options table by specifying
the option value in the component.

```lua
options = {
  theme = 'nord', -- tabline theme
  section_separators = {
    left = wezterm.nerdfonts.ple_right_half_circle_thick,
    right = wezterm.nerdfonts.ple_left_half_circle_thick,
  },
  component_separators = {
    left = wezterm.nerdfonts.ple_right_half_circle_thin,
    right = wezterm.nerdfonts.ple_left_half_circle_thin,
  },
  tab_separators = {
    left = wezterm.nerdfonts.ple_right_half_circle_thick,
    right = wezterm.nerdfonts.ple_left_half_circle_thick,
  },
}
```

#### General component options

These are options that control behavior at the component level
and are available for all components.

```lua
sections = {
  status_left = {
    {
      'workspace',
      icons_enabled = true, -- Enables the display of icons alongside the component.
      -- Defines the icon to be displayed in front of the component.
      -- Can be string|table
      -- As table it must contain the icon as first entry and can use
      -- color option to custom color the icon. Example:
      -- { 'workspace', icon = wezterm.nerdfonts.cod_terminal_tmux } / { 'workspace', icon = { wezterm.nerdfonts.cod_terminal_tmux, color = { fg= '#00ff00' } } }

      icons_only = false, -- Only show icon (if the component has one)

      -- icon position can also be set to the right side from table. Example:
      -- {'branch', icon = { wezterm.nerdfonts.cod_terminal_tmux, align = 'right', color = { fg = '#00ff00' } } }
      icon = nil,

      cond = nil, -- Condition function, the component is loaded when the function returns `true`.

      padding = 1, -- Adds padding to the left and right of components.
                   -- Padding can be specified to left or right independently, e.g.:
                   --   padding = { left = left_padding, right = right_padding }

      fmt = nil, -- Format function, formats the component's output.
      -- This function receives two arguments:
      -- - string that is going to be displayed and
      --   that can be changed, enhanced and etc.
      -- - Window/TabInformation object with information you might
      --   need. E.g. active_pane if used with Window.
    },
  },
}
```

#### Component specific options

These are options that are available on specific components.
For example, you have option on `index` component to
specify if it should be zero indexed.

#### datetime component options

```lua
sections = {
  status_right = {
    {
      'datetime',
      -- options: your own format string ('%Y/%m/%d %H:%M:%S', etc.)
      style = '%H:%M',
      hour_to_icon = {
        ['00'] = wezterm.nerdfonts.md_clock_time_twelve_outline,
        ['01'] = wezterm.nerdfonts.md_clock_time_one_outline,
        ['02'] = wezterm.nerdfonts.md_clock_time_two_outline,
        -- for every hour...
        ['23'] = wezterm.nerdfonts.md_clock_time_eleven,
      },
    -- hour_to_icon is a table that maps hours to icons it overwrites the default icon property.
    -- To use the default icon property set hour_to_icon to nil.
    -- The color and align properties can still be used on the icon property.
    },
  },
}
```

#### cwd and parent component options

```lua
sections = {
  tab_active = {
    {
      'cwd',
      max_length = 10, -- Max length before it is truncated
    },
  },
}
```

#### index component options

```lua
sections = {
  tab_active = {
    {
      'index',
      zero_indexed = false, -- Does the tab index start at 0 or 1
    },
  },
}
```

#### process component options

```lua
sections = {
  tab_active = {
    {
      'process',
      process_to_icon = {
        ['apt'] = wezterm.nerdfonts.dev_debian,
        ['bash'] = wezterm.nerdfonts.cod_terminal_bash,
        ['bat'] = wezterm.nerdfonts.md_bat,
        ['cmd.exe'] = wezterm.nerdfonts.md_console_line,
        ['curl'] = wezterm.nerdfonts.md_flattr,
        ['debug'] = wezterm.nerdfonts.cod_debug,
        ['default'] = wezterm.nerdfonts.md_application,
        ['docker'] = wezterm.nerdfonts.linux_docker,
        ['docker-compose'] = wezterm.nerdfonts.linux_docker,
        ['git'] = wezterm.nerdfonts.dev_git,
        ['go'] = wezterm.nerdfonts.md_language_go,
        ['lazydocker'] = wezterm.nerdfonts.linux_docker,
        ['lazygit'] = wezterm.nerdfonts.cod_github,
        ['lua'] = wezterm.nerdfonts.seti_lua,
        ['make'] = wezterm.nerdfonts.seti_makefile,
        ['nix'] = wezterm.nerdfonts.linux_nixos,
        ['node'] = wezterm.nerdfonts.md_nodejs,
        ['npm'] = wezterm.nerdfonts.md_npm,
        ['nvim'] = wezterm.nerdfonts.custom_neovim,
        ['psql'] = wezterm.nerdfonts.dev_postgresql,
        ['zsh'] = wezterm.nerdfonts.dev_terminal,
        -- and more...
      },
    -- process_to_icon is a table that maps process to icons
    },
  },
}
```

#### cpu and ram component options

```lua
sections = {
  status_right = {
    {
      'cpu',
      throttle = 3, -- How often in seconds the component updates, set to 0 to disable throttling
    },
  },
}
```

#### battery component options

```lua
sections = {
  status_right = {
    {
      'battery',
      battery_to_icon = {
        empty = { wezterm.nerdfonts.fa_battery_empty, color = { fg = scheme.ansi[2] } },
        quarter = wezterm.nerdfonts.fa_battery_quarter,
        half = wezterm.nerdfonts.fa_battery_half,
        three_quarters = wezterm.nerdfonts.fa_battery_three_quarters,
        full = wezterm.nerdfonts.fa_battery_full,
      },
      -- battery_to_icon is a table that maps battery percentage to icons
      -- It overwrites the default icon property. To use the default icon property set battery_to_icon to nil
      -- The color and align properties can still be used on the icon property
    },
  },
}
```

#### domain component options

```lua
sections = {
  status_right = {
    {
      'domain',
      domain_to_icon = {
        default = wezterm.nerdfonts.md_monitor,
        ssh = wezterm.nerdfonts.md_ssh,
        wsl = wezterm.nerdfonts.md_microsoft_windows,
        docker = wezterm.nerdfonts.md_docker,
        unix = wezterm.nerdfonts.cod_terminal_linux,
      },
    },
  },
}
```

#### output component options

```lua
sections = {
  tab_inactive = {
    {
      'output',
      icon_no_output = wezterm.nerdfonts.md_bell_outline, -- Which icon to show when there is no unseen output. Can be set to nil if you only want to show an icon when there is unseen output.
    },
  },
}
```

---

### Refreshing tabline

By default tabline refreshes itself based on the
[`status_update_interval`](https://wezfurlong.org/wezterm/config/lua/config/status_update_interval.html).
However you can also force tabline to refresh at any time by calling
`tabline.refresh` function. The refresh function needs the Window object to
refresh the tabline, and the TabInformation object to refresh the tabs. If
passing one of them as nil it won't refresh the respective section.

```lua
tabline.refresh(window, tab)
```

Avoid calling `tabline.refresh` inside components. Since components are
evaluated during refresh, calling refresh while refreshing can have undesirable
effects.

### Disabling tabline

You can also disable tabline completely. By setting the
[enable_tab_bar](https://wezfurlong.org/wezterm/config/lua/config/enable_tab_bar.html)
option to false in the WezTerm config.

### Inspiration

Thanks to [MLFlexer](https://github.com/MLFlexer) for some tips in developing a
plugin for WezTerm.

Thanks to [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) for the
inspiration and a nice statusline for my Neovim.
