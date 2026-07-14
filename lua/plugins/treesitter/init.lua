local M = {}

function M.setup()
    vim.api.nvim_create_autocmd('PackChanged', {
        callback = function(ev)
            if ev.data.spec.name == 'nvim-treesitter' then
                vim.cmd 'TSUpdate'
            end
        end,
    })

    vim.pack.add {
        { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
    }

    require('nvim-treesitter').setup()
    require('nvim-treesitter').install {
        'rust',
        'go',
        'typescript',
        'tsx',
        'javascript',
        'c',
        'cpp',
        'ocaml',
        'haskell',
        'lua',
        'vim',
        'vimdoc',
        'markdown',
        'markdown_inline',
        'bash',
        'zig',
        'python',
        'html',
        'diff',
    }

    vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'rust', 'go', 'typescript', 'javascript', 'c', 'cpp', 'ocaml', 'haskell', 'lua' },
        callback = function()
            vim.treesitter.start()
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end,
    })

    require('plugins.treesitter.textobjects').setup()
end

return M
