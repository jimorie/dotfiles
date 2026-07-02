-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  -- Adds git related signs to the gutter, as well as utilities for managing changes
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        vim.keymap.set('n', 'K', function()
          if vim.wo.diff then
            return 'K'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
        vim.keymap.set('n', 'I', function()
          if vim.wo.diff then
            return 'I'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })

        -- Actions
        vim.keymap.set('n', '<leader>gs', gs.stage_hunk, { desc = 'Stage hunk' })
        vim.keymap.set('n', '<leader>gr', gs.reset_hunk, { desc = 'Reset hunk' })
        vim.keymap.set('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
        vim.keymap.set('n', '<leader>gS', gs.stage_buffer, { desc = 'Stage buffer' })
        vim.keymap.set('n', '<leader>gR', gs.reset_buffer, { desc = 'Reset buffer' })
        vim.keymap.set('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview hunk' })
        vim.keymap.set('n', '<leader>gb', gs.toggle_current_line_blame, { desc = 'Blame line' })

        -- Text object
        vim.keymap.set({'o', 'x'}, 'hh', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select current change hunk' })

      end,
    },
  },

  {
    -- Themes
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      require('onedark').setup  {
        transparent = {
            lualine = true,
            background = true,
            tabline = true,
            statusline = true,
        },
        colors = {
          black = '#080808',
          bg0 = vim.env.COLOR_BG,
          bg1 = vim.env.COLOR_DIM_BG,
          bg2 = 'NONE',
          bg3 = '#585858',
          bg4 = '#6c6c6c',
        },
        highlights = {
          ["CursorLine"] = { bg = '#141414' },
          ["CursorLineNr"] = { fg = '$orange' },
          -- Does not seem to work, but would be nice to have...
          -- ["NvimTreeOpenedFile"] = { fg = '$orange' },
          -- ["NvimTreeOpenedHL"] = { fg = '$orange' },
        }
      }
      vim.cmd.colorscheme 'onedark'
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    config = function()
      local custom_theme = require 'lualine.themes.onedark'
      custom_theme.command.a = {fg = '#ffffff', bg = vim.env.COLOR_DIM_YELLOW}
      custom_theme.insert.a = {fg = '#ffffff', bg = vim.env.COLOR_DIM_BLUE}
      custom_theme.visual.a = {fg = '#ffffff', bg = vim.env.COLOR_DIM_MAGENTA}
      custom_theme.normal.a = {fg = '#ffffff', bg = vim.env.COLOR_DIM_GREEN}
      custom_theme.terminal.a = {fg = '#ffffff', bg = vim.env.COLOR_DIM_CYAN}
      custom_theme.replace.a = {fg = '#ffffff', bg = vim.env.COLOR_RED}
			-- Override 'encoding': Don't display if encoding is UTF-8.
			encoding = function()
				local ret, _ = (vim.bo.fenc or vim.go.enc):gsub("^utf%-8$", "")
				return ret
			end
			-- fileformat: Don't display if &ff is unix.
			fileformat = function()
				local ret, _ = vim.bo.fileformat:gsub("^unix$", "")
				return ret
			end
      branchfmt = function(name, context)
        if #name < 20 then
          return name
        end
        name = string.gsub(name, '^.*/', '…/')
        if #name < 20 then
          return name
        end
        return string.sub(name, 1, 19) .. "…"
      end
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = custom_theme,
          component_separators = '',
          section_separators = {left ='', right = ''},
          globalstatus = true,
        },
        sections = {
          lualine_a = {{ 'mode', separator = { left = '', right = '' }}},
          lualine_b = {{ 'filename', icons_enabled = true, path = 1, file_status = false, separator = { right = ''}}},
          lualine_c = {},
          lualine_x = {{'%B', padding = 0, fmt = function(s, c) return "0x" .. s end}, 'location'},
          lualine_y = {fileformat, encoding, 'filetype'},
          lualine_z = {{'branch', icon = '', color = {fg = '#ffffff', bg = vim.env.COLOR_DIM_CYAN}, fmt = branchfmt, separator = { left = '', right = '' }}},
        }
      }
    end,
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- or if using mini.icons/mini.nvim
    -- dependencies = { "nvim-mini/mini.icons" },
    opts = {},
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
  },

	{
			"kylechui/nvim-surround",
			version = "*", -- Use for stability; omit to use `main` branch for the latest features
			event = "VeryLazy",
			config = function()
					require("nvim-surround").setup({
            move_cursor = "sticky",
					})
			end
	},

  -- {
  --   "supermaven-inc/supermaven-nvim",
  --   config = function()
  --     require("supermaven-nvim").setup({
  --       keymaps = {
  --         accept_suggestion = "<Tab>",
  --         clear_suggestion = "<S-Tab>",
  --         accept_word = "<C-k>",
  --       },
  --       color = {
  --         suggestion_color = "#5f5f87",
  --         cterm = 60,
  --       },
  --     })
  --   end,
  -- },

  'Vimjas/vim-python-pep8-indent',
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- Keep some lines around the cursor
vim.o.scrolloff = 10

-- Highlight current line
vim.o.cursorline = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.hl_op()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure fzf-lua ]]
local fzf_lua = require "fzf-lua"
local fzf_utils = require "fzf-lua.utils"

local function selection_or_cword(boundary)
  local selection = fzf_utils.mode_is_visual() and fzf_utils.get_visual_selection() or nil

  if not selection then
    selection = vim.fn.expand("<cword>")
    if selection and selection ~= "" and boundary then
      selection = "\\b" .. selection .. "\\b"
    end
  end

  return selection
end

find_project_definitions = function(opts)
  if vim.fn.executable("ctags") == 0 then
    vim.notify("ctags executable not found", vim.log.levels.WARN)
    return
  end

  if vim.fn.executable("rg") == 0 then
    vim.notify("rg executable not found", vim.log.levels.WARN)
    return
  end

  opts = opts or {}
  local ctags_cmd = "rg --files --follow -g '*.py' | ctags -L - -f - --fields=+n --extra=+q --sort=no --python-kinds=+cfmv-i 2>/dev/null"

  return fzf_lua.tags(vim.tbl_deep_extend("force", {
    cwd = vim.uv.cwd(),
    cmd = ctags_cmd,
    ctags_autogen = true,
    -- previewer = "bat",
    file_icons = false,
    silent = true,
    actions = {
      ["ctrl-g"] = false,
    },
  }, opts))
end

fzf_lua.setup {
  defaults = {
    git_icons = false,
    prompt = '❯ ',
    actions = {
      ["ctrl-b"] = function(_, opts)
        fzf_lua.buffers({ query = opts.last_query })
      end,
      ["ctrl-f"] = function(_, opts)
        fzf_lua.files({ query = opts.last_query, cwd_prompt = false })
      end,
      ["ctrl-g"] = function(_, opts)
        fzf_lua.live_grep({ regex = opts.last_query })
      end,
      ["ctrl-v"] = function(_, opts)
        fzf_lua.live_grep({ regex = vim.fn.getreg('"+') })
      end,
      ["ctrl-o"] = function()
        fzf_lua.jumps()
      end,
      ["ctrl-t"] = function(_, opts)
        find_project_definitions({ query = opts.last_query })
      end,
    },
  },
  fzf_opts = {
    ['--layout'] = 'default',
  },
  winopts = {
    treesitter = false,
    preview = {
      layout = "flex",
      flip_columns = 200,
      vertical = "up:66%",
      default = "bat", -- Requires 'bat' installed on your system
    },
  },
  previewers = {
    builtin = {
      treesitter = {
        enabled = false,
      },
    },
  },
  buffers = {
    filename_only = false,
    -- ignore_current_buffer = true,
  },
  grep = {
    follow = true,
    no_esc = true,
    actions = {
      ["ctrl-g"] = false,
    },
    fzf_opts = {
      ["--disabled"] = true,
    },
  },
  tags = {
    follow = true,
    actions = {
      ["ctrl-g"] = false,
    },
  },
  lsp = {
    workspace_symbols = {
      actions = {
        ["ctrl-g"] = false,
      },
    },
  },
  files = {
    follow = true,
    -- formatter = "path.filename_first",
  },
  keymap = {
    fzf = {
      ["ctrl-c"] = "abort",
    },
  },
}

vim.keymap.set({"n", "v"}, "<C-p>", fzf_lua.buffers, { desc = 'Fuzzy find buffers and files' })
vim.keymap.set({"n", "v"}, "<C-t>", function()
  find_project_definitions({ query = selection_or_cword(false) })
end, { desc = 'Find project definitions' })
vim.keymap.set({"n", "v"}, "<C-g>", function()
  fzf_lua.live_grep({ regex = selection_or_cword(true) })
end, { desc = 'Live grep selection or word' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true; disable = { "python" } },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ha'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['hf'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['hc'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- document existing key chains
--require('which-key').register {
--  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
--  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
--  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
--  ['<leader>h'] = { name = 'More git', _ = 'which_key_ignore' },
--  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
--  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
--  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
--}

-- configure nvim-tree

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- OR setup with some options
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = {min = 30, max = 90},
  },
  renderer = {
    group_empty = true,
    symlink_destination = false,
  },
  modified = {
    enable = false,
  },
  filters = {
    dotfiles = true,
    custom = {"__pycache__"},
  },
  hijack_cursor = true,
  update_focused_file = {
    enable = true,
  },
})

vim.keymap.set('n', '<leader>t', ':NvimTreeToggle<cr>', { desc = 'Toggle nvim-tree' })

vim.api.nvim_command('source ~/.config/nvim/keybinds.vim')

-- Configure cursorline to only show when focused
vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained" }, {
  callback = function()
    local ok, cl = pcall(vim.api.nvim_win_get_var, 0, "auto-cursorline")
    if ok and cl then
      vim.wo.cursorline = true
      vim.api.nvim_win_del_var(0, "auto-cursorline")
    end
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave", "FocusLost" }, {
  callback = function()
    local cl = vim.wo.cursorline
    if cl then
      vim.api.nvim_win_set_var(0, "auto-cursorline", cl)
      vim.wo.cursorline = false
    end
  end,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
