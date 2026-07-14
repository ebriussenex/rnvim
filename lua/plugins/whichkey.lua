local M = {}

function M.setup()
    vim.pack.add { { src = 'https://github.com/folke/which-key.nvim' } }

    require('which-key').setup {
        preset = 'modern',
        delay = 300, -- sync with timeoutlen
    }

    require('which-key').add {
        { '<leader>s', group = '[s]earch' },
        { '<leader>b', group = '[b]uffer' },
        { '<leader>t', group = '[t]oggle/[t]erminal' },
        { '<leader>u', group = '[U]I' },
        { '<leader>d', group = '[d]ebug' },
        { '<leader>h', group = 'git [h]unk' },
    }
end

return M
