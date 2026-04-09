-- [[ General Settings ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- [[ Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Quickfix' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>')
vim.keymap.set('n', '<C-l>', '<C-w><C-l>')
vim.keymap.set('n', '<C-j>', '<C-w><C-j>')
vim.keymap.set('n', '<C-k>', '<C-w><C-k>')
vim.keymap.set('t', '<C-q>', [[<C-\><C-n>]], { desc = 'Exit terminal' })
vim.keymap.set('i', '<C-h>', '<C-o>^')
vim.keymap.set('i', '<C-l>', '<C-o>$')
vim.keymap.set('n', '<C-->', '<cmd>split<CR>', { desc = 'Horizontal split' })
vim.keymap.set('n', '<C-\\>', '<cmd>vsplit<CR>', { desc = 'Vertical split' })

vim.keymap.set('n', '<leader>r', function()
  vim.cmd('vsplit | term python3 ' .. vim.fn.expand('%'))
end, { desc = 'Run Python file' })

-- [[ Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'TermOpen' }, {
  pattern = 'term://*',
  callback = function() vim.cmd('startinsert') end,
})

-- [[ Plugin Manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'NMAC427/guess-indent.nvim',
  { 'lewis6991/gitsigns.nvim', opts = { signs = { add = { text = '+' }, change = { text = '~' }, delete = { text = '_' } } } },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      require('gruvbox').setup({ terminal_colors = true, inverse = true })
      vim.cmd.colorscheme 'gruvbox'
    end,
  },
  'luisjure/csound-vim',
  {
    'lervag/vimtex',
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_compiler_latexmk_engines = { [''] = '-xelatex', ['_'] = '-xelatex' }
      vim.g.vimtex_view_forward_search_on_start = true
      vim.g.vimtex_view_zathura_options = '--synctex-forward %line:1:%file'

      vim.keymap.set('n', '<leader>ls', '<cmd>VimtexView<CR>', { desc = 'VimTeX: Forward Search/Sync' })

      -- [[ VimTeX Keymaps ]]
      vim.keymap.set('n', '<leader>li', '<cmd>VimtexCompile<CR>', { desc = 'VimTeX: Start/Stop Compilation' })
      vim.keymap.set('n', '<leader>lk', '<cmd>VimtexStop<CR>', { desc = 'VimTeX: Stop Compilation' })
      vim.keymap.set('n', '<leader>lv', '<cmd>VimtexView<CR>', { desc = 'VimTeX: View PDF' })
      vim.keymap.set('n', '<leader>lc', '<cmd>VimtexClean<CR>', { desc = 'VimTeX: Clean' })
      vim.keymap.set('n', '<leader>le', '<cmd>VimtexErrors<CR>', { desc = 'VimTeX: Show Errors' })
    end,
  },
  { 'NotAShelf/direnv.nvim', config = true },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
    opts = {
      lsp = { override = { ['vim.lsp.util.convert_input_to_markdown_lines'] = true, ['cmp.entry.get_documentation'] = true } },
      presets = { bottom_search = true, command_palette = false, lsp_doc_border = true },
    },
  },
  { 'folke/which-key.nvim', event = 'VimEnter', opts = { delay = 0 } },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' } },
    config = function()
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sf', builtin.find_files)
      vim.keymap.set('n', '<leader>sg', builtin.live_grep)
      vim.keymap.set('n', '<leader><leader>', builtin.buffers)
    end,
  },
  { 'williamboman/mason.nvim', opts = {} },
  { 'williamboman/mason-lspconfig.nvim', opts = { ensure_installed = { 'pyright', 'lua_ls' } } },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      vim.lsp.config('pyright', {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            }
          }
        }
      })

      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
      })

      vim.lsp.enable('pyright')
      vim.lsp.enable('lua_ls')
    end,
  },
  { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
  { 'stevearc/conform.nvim', opts = { formatters_by_ft = { lua = { 'stylua' }, python = { 'ruff_format' } } } },
  {
    'saghen/blink.cmp',
    version = 'v0.*',
    opts = {
      keymap = { preset = 'default' },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
  },
  { 'folke/todo-comments.nvim', opts = { signs = false } },
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'c', 'python', 'lua', 'markdown', 'latex' },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      pcall(function()
        for _, parser in ipairs(opts.ensure_installed) do
          vim.cmd('TSInstall ' .. parser)
        end
      end)
    end,
  },
  { 'stevearc/dressing.nvim', event = 'VeryLazy', opts = {} },
}, { ui = { icons = {} } })

pcall(require, 'custom.autocmds')

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function() vim.cmd 'colorscheme gruvbox' end,
})

-- [[ VimTeX Auto-Cleanup on Exit ]]
vim.api.nvim_create_autocmd('VimLeave', {
  group = vim.api.nvim_create_augroup('vimtex_cleanup', { clear = true }),
  pattern = '*',
  callback = function()
    pcall(vim.cmd, 'VimtexClean')
  end,
})

