local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end
    vim.pack.add { { src = gh 'folke/snacks.nvim' } }
    require('snacks').setup {
        input = { enabled = true },
        -- TODO: look for these later
        picker = { enabled = false },
        explorer = { enabled = false },
        words = { enabled = false },
        statuscolumn = { enabled = false },
        indent = { enabled = false },
        dashboard = { enabled = false },
        scratch = { enabled = false },
        zen = { enabled = false },
        notifier = { enabled = false },
    }
end

return M
