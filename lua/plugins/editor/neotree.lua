local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end

    require('plugins.editor.icons').setup()
    vim.pack.add {
        { src = gh 'nvim-lua/plenary.nvim' },
        { src = gh 'MunifTanjim/nui.nvim' },
        { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '3' },
    }

    require('neo-tree').setup {
        close_if_last_window = false,
        filesystem = {
            follow_current_file = { enabled = true },
            filtered_items = {
                visible = true,
                hide_hidden = false,
                hide_dotfiles = false,
                hide_gitignored = false,
            },
        },
        window = {
            width = 32,
            mappings = {
                ['<space>'] = 'none',
                ['\\'] = 'close_window',
            },
        },
    }

    vim.keymap.set('n', '<leader>\\', '<cmd>Neotree toggle<cr>', { desc = '[neotree] toggle' })
end

return M
