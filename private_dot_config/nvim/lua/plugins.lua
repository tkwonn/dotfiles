return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    
    -- Color Theme
    use { "catppuccin/nvim", as = "catppuccin" }
    
    -- Status Line
    use 'nvim-lualine/lualine.nvim'
    
    -- Remember last cursor position
    use 'ethanholz/nvim-lastplace'
    
    -- Syntax Highlight
    use {
      'nvim-treesitter/nvim-treesitter',
      run = function()
        require('nvim-treesitter.install').update({ with_sync = true })
      end,
    }
    
    -- Formatter
    use 'jose-elias-alvarez/null-ls.nvim'
    use 'MunifTanjim/prettier.nvim'
    
    -- Indent Line
    use 'lukas-reineke/indent-blankline.nvim'
    
    -- LSP
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'
  end)