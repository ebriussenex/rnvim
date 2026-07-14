local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end
    vim.pack.add { { src = gh 'folke/snacks.nvim' } }
    require('snacks').setup {
        input = { enabled = true },
        indent = {
            enabled = true,
            animate = {
                enabled = false,
            },
            indent = {
                char = '│',
                only_scope = false,
                only_current = false,
            },
            scope = {
                enabled = true,
                char = '│',
                underline = false,
            },
        },
        -- TODO: look for these later
        picker = { enabled = false },
        explorer = { enabled = false },
        words = { enabled = false },
        statuscolumn = { enabled = false },
        dashboard = { enabled = false },
        scratch = { enabled = false },
        zen = { enabled = false },
        notifier = { enabled = false },
    }

    vim.keymap.set('n', '<leader>ui', function()
        local snacks_indent = require('snacks').indent
        if snacks_indent.enabled then
            snacks_indent.disable()
        else
            snacks_indent.enable()
        end
    end, { desc = '[U]I toggle [i]ndent guides' })
end

return M
