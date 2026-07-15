local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end

    vim.pack.add {
        { src = gh 'folke/lazydev.nvim' },
        { src = gh 'LuaCATS/busted' },
        { src = gh 'LuaCATS/luassert' },
    }

    local data = vim.fn.stdpath 'data'
    local pack_dir = data .. '/site/pack/core/opt/'

    require('lazydev').setup {
        library = {
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            { path = pack_dir .. 'busted/library', words = { 'describe', 'it', 'before_each', 'after_each', 'pending', '' } },
            { path = pack_dir .. 'luassert/library', words = { 'assert' } },
            -- NOTE: luassert: equals, same, is_true and other are not static fields
            -- and we need this to fix diagnostics, desribing meta
            { path = vim.fn.stdpath 'config' .. '/lua/plugins/lsp/meta', words = { 'assert' } },
        },
    }
end

return M
