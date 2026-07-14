local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end
    vim.pack.add { { src = gh 'folke/todo-comments.nvim' } }

    require('todo-comments').setup {
        signs = true,
    }

    vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<cr>', { desc = '[s]earch [t]odos' })
end

return M
