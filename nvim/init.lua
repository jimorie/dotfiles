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
          bg0 = '#1c1c1c',
          bg1 = '#303030',
          bg2 = 'NONE',
          bg3 = '#585858',
          bg4 = '#6c6c6c',
        },
        highlights = {
          ["CursorLine"] = { bg = '#141414' },
          ["CursorLineNr"] = { fg = '$orange' },
        }
      }
      vim.cmd.colorscheme 'onedark'
    end,
  },

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

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

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
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

-- Diagnostic keymaps
--vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
--vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
  pickers = {
    buffers = {
      ignore_current_buffer = true,
      sort_lastused = true,
      sort_mru = true,
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == "" then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = {git_root},
    })
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<C-p>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
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
