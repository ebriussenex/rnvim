local gh = function(x)
    return 'https://github.com/' .. x
end

vim.pack.add {
    { src = gh 'neovim/nvim-lspconfig' },
    { src = gh 'mason-org/mason.nvim' },
    { src = gh 'mason-org/mason-lspconfig.nvim' },
}

require('mason').setup {
    firewall = {
        enabled = true,
    },
    PATH = 'append',
    max_concurrent_installers = 10,
    ui = {
        icons = {
            package_pending = ' ',
            package_installed = ' ',
            package_uninstalled = ' ',
        },
    },
}

require('mason-lspconfig').setup {
    ensure_installed = {
        'rust_analyzer',
        'lua_ls',
        'clangd',
        'gopls',
        'ts_ls',
        'ocamllsp',
        'hls',
    },
    automatic_enable = true,
}

require 'plugins.lsp.servers.lua_ls'

-- on attach - autocmds for lsp
require('plugins.lsp.attach').setup()
require('plugins.lsp.lazydev').setup()
