local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end
    vim.pack.add {
        { src = gh 'L3MON4D3/LuaSnip' },
        { src = gh 'rafamadriz/friendly-snippets' },
    }

    require('luasnip').config.setup {}

    require('luasnip.loaders.from_vscode').lazy_load()

    require('luasnip.loaders.from_lua').lazy_load {
        paths = vim.fn.stdpath 'config' .. '/lua/snippets',
    }
end

return M
