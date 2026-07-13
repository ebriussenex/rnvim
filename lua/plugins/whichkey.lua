local M = {}

function M.setup()
    vim.pack.add { { src = 'https://github.com/folke/which-key.nvim' } }

    require('which-key').setup {
        preset = 'modern',
        delay = 300, -- sync with timeoutlen
    }

    require('which-key').add {
        { '<leader>s', group = '[s]earch' },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>t', group = '[T]oggle' },
    }
end

return M
