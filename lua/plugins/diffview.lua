local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end
    vim.pack.add { { src = gh 'sindrets/diffview.nvim' } }

    require('diffview').setup {
        use_icons = true,
    }

    vim.keymap.set('n', '<leader>hM', function()
        vim.ui.input({ prompt = 'Diff against branch: ', default = 'master' }, function(branch)
            if branch and branch ~= '' then
                vim.cmd('DiffviewOpen ' .. branch)
            end
        end)
    end, { desc = 'git diff vs [M]aster/branch' })

    vim.keymap.set('n', '<leader>hq', '<cmd>DiffviewClose<cr>', { desc = 'git diff view [q]uit' })
end

return M
