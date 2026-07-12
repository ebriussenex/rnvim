local M = {}

function M.setup()
    vim.pack.add { { src = 'https://github.com/folke/lazydev.nvim' } }

    require('lazydev').setup {
        library = {
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
    }
end

return M
