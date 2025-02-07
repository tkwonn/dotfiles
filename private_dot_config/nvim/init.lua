require('plugins')

vim.cmd('syntax enable')
vim.cmd('syntax on')

-- Moving around, searching and patterns
vim.opt.whichwrap='b,s,h,l,<,>,[,]' -- list of flags specifying which commands wrap to another line

-- Displaying text
vim.opt.scrolloff=5 -- number of screen lines to show around the cursor
vim.opt.wrap=false -- long lines wrap
vim.opt.sidescrolloff=5 -- minimal number of columns to keep left and right of the cursor
vim.opt.number=true -- show the line number for each line

-- Syntax, highlighting and spelling
vim.opt.termguicolors=true -- use GUI colors for the terminal
vim.opt.cursorline=true -- highlight the screen line of the cursor

--  Using the mouse
vim.opt.mouse='a' -- list of flags for using the mouse

-- Messages and info
vim.opt.showmode=false -- display the current mode in the status line

-- Editing text
vim.opt.undolevels=10000 -- maximum number of changes that can be undone
vim.opt.undofile=true -- automatically save and restore undo history

-- Tabs and Indentation
vim.opt.tabstop=4 -- number of spaces a <Tab> in the text stands for
vim.opt.shiftwidth=4 -- number of spaces used for each step of (auto)indent
vim.opt.smarttab=false -- a <Tab> in an indent inserts 'shiftwidth' spaces
vim.opt.shiftround=true -- round to 'shiftwidth' for --<<-- and -->>--
vim.opt.expandtab=true -- expand <Tab> to spaces in Insert mode
vim.opt.smartindent=true -- do clever autoindenting

-- Clibboard Support
vim.opt.clipboard:append{'unnamed'}

-- Key mapping 
vim.keymap.set('i', 'jk', '<Esc>')

vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0

-- Add custom site directory to runtimepath/packpath
vim.opt.runtimepath:append(vim.env.VIM .. '/site')
vim.opt.packpath:append(vim.env.VIM .. '/site')

-- Guess background color
if vim.env.TERM_BG == "light" then
  vim.opt.background = "light"
  vim.g.catppuccin_flavour = "latte"
else
  -- MacOS Terminal, WSL terminal, and most linux terminals default to a black background, so fallback to "dark"
  vim.opt.background = "dark"  
  vim.g.catppuccin_flavor = "mocha"
end


require("catppuccin").setup {
  styles = {
    comments = { "italic" },
  },
	highlight_overrides = {
		latte = {
			Normal = { bg = "#ffffff", fg = "#080808" },
      Comment = { fg = "#8c6cac" },
		},
	}
}

vim.cmd [[colorscheme catppuccin]]
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "background",
	callback = function()
		vim.cmd("Catppuccin " .. (vim.v.option_new == "light" and "latte" or "mocha"))
	end,
})

-- Turn on lualine 
require('lualine').setup {
  icons_enabled = false,
	options = {
		theme = "catppuccin"
	},
  sections = {
    lualine_b = {'branch', 'diff', {'diagnostics', symbols = {error = 'E ', warn = 'W ', info = 'I ', hint = 'H '}, update_in_insert = true,}},
    lualine_x = {'encoding', {'fileformat', symbols = { unix = 'unix', dos = 'dos', mac = 'mac' }}, 'filetype'}
  }
}

-- Turn on last place (remember where you were when reopening a file)
require'nvim-lastplace'.setup{}


-- Turn on treesitter
require'nvim-treesitter.configs'.setup {
  highlight = {
    -- `false` will disable the whole extension
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  matchup = {
    enable = true,
    include_match_words = true,
  }
}

local null_ls = require("null-ls")

null_ls.setup({
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      vim.cmd("nnoremap <silent><buffer> <Leader>f :lua vim.lsp.buf.formatting()<CR>")

      -- format on save
      vim.cmd("autocmd BufWritePost <buffer> lua vim.lsp.buf.formatting()")
    end

    if client.server_capabilities.documentRangeFormattingProvider then
      vim.cmd("xnoremap <silent><buffer> <Leader>f :lua vim.lsp.buf.range_formatting({})<CR>")
    end
  end,
})

local prettier = require("prettier")

prettier.setup({
  bin = 'prettier', 
  filetypes = {
    "css",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "less",
    "markdown",
    "scss",
    "typescript",
    "typescriptreact",
    "yaml",
  },
})

-- Turn on indentline
vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"

require("ibl").setup {
  enabled = true,
  scope = {
    enabled = false,
  },
  indent = {
    char = "│",
  },
}


local lspconfig = require('lspconfig')

local lsp_defaults = {
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  on_attach = function(client, bufnr)
    vim.api.nvim_exec_autocmds('User', {pattern = 'LspAttached'})
  end
}

lspconfig.util.default_config = vim.tbl_deep_extend(
  'force',
  lspconfig.util.default_config,
  lsp_defaults
  )

local util = require 'lspconfig.util'

local root_files = {
  'compile_commands.json',
  '.ccls',
}

require'lspconfig'.ccls.setup {
  single_file_support = true,
  root_dir = function(fname)
      return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname) or vim.loop.cwd()
  end,
  init_options = {
    cache = {
      directory = "";
    },
    completion = {
      placeholder = false;
    },
    diagnostics = {
      onOpen = 0,
      onChange = 1,
      onSave = 0,
    }
  },
}


vim.api.nvim_create_autocmd('User', {
  pattern = 'LspAttached',
  desc = 'LSP actions',
  callback = function()
    local bufmap = function(mode, lhs, rhs)
      local opts = {buffer = true}
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Displays hover information about the symbol under the cursor
    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

    -- Jump to the definition
    bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

    -- Jump to declaration
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

    -- Lists all the implementations for the symbol under the cursor
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

    -- Jumps to the definition of the type symbol
    bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

    -- Lists all the references 
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

    -- Displays a function's signature information
    bufmap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

    -- Renames all references to the symbol under the cursor
    bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

    -- Selects a code action available at the current cursor position
    bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    bufmap('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')

    -- Show diagnostics in a floating window
    bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

    -- Move to the previous diagnostic
    bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

    -- Move to the next diagnostic
    bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')


    bufmap('n', '<Leader>f', '<cmd>lua vim.lsp.buf.formatting()<cr>')
    bufmap('x', '<Leader>f', '<cmd>lua vim.lsp.buf.range_formatting()<cr>')
  end
})

vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

local cmp = require('cmp')
local luasnip = require('luasnip')

local select_opts = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end
  },
  sources = {
    {name = 'nvim_lsp_signature_help'},
    {name = 'path'},
    {name = 'nvim_lsp', keyword_length = 3},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  },
  window = {
    documentation = cmp.config.window.bordered()
  },
  formatting = {
    fields = {'menu', 'abbr', 'kind'},
    format = function(entry, item)
      local menu_icon = {
        nvim_lsp = 'λ',
        luasnip = '⋗',
        buffer = 'Ω',
        path = '🖫',
      }
      item.menu = menu_icon[entry.source.name]
      return item
    end,
  },
  mapping = {
    ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
    ['<Down>'] = cmp.mapping.select_next_item(select_opts),

    ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
    ['<C-n>'] = cmp.mapping.select_next_item(select_opts),

    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),

    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm(),


    ['<Tab>'] = cmp.mapping(function(fallback)
      local col = vim.fn.col('.') - 1

      if cmp.visible() then
        cmp.select_next_item(select_opts)
      elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        fallback()
      else
        cmp.complete()
      end
    end, {'i', 's'}),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item(select_opts)
      else
        fallback()
      end
    end, {'i', 's'}),
  },
})

