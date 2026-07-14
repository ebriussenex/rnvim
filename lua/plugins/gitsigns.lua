local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end
    vim.pack.add { { src = gh 'lewis6991/gitsigns.nvim' } }

    require('gitsigns').setup {
        signs = {
            add = { text = '+' },
            change = { text = '~' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
            local gitsigns = require 'gitsigns'
            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- navigation
            map('n', ']c', function()
                if vim.wo.diff then
                    vim.cmd.normal { ']c', bang = true }
                else
                    gitsigns.nav_hunk 'next'
                end
            end, { desc = 'jump to next git [c]hange' })
            map('n', '[c', function()
                if vim.wo.diff then
                    vim.cmd.normal { '[c', bang = true }
                else
                    gitsigns.nav_hunk 'prev'
                end
            end, { desc = 'jump to previous git [c]hange' })

            -- actions
            map('v', '<leader>hs', function()
                gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
            end, { desc = 'stage git hunk' })
            map('v', '<leader>hr', function()
                gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
            end, { desc = 'reset git hunk' })
            map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
            map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
            map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
            map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo/toggle stage hunk' })
            map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
            -- TODO: not working?
            map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
            map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
            map('n', '<leader>hd', function()
                if vim.wo.diff then
                    vim.cmd 'diffoff'
                    vim.cmd 'close'
                else
                    gitsigns.diffthis()
                end
            end, { desc = 'git [d]iff against index (toggle)' })
            map('n', '<leader>hD', function()
                gitsigns.diffthis '@'
            end, { desc = 'git [D]iff against last commit' })

            -- toggles
            map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[t]oggle git show [b]lame line' })
            map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline' })
        end,
    }
end

return M
