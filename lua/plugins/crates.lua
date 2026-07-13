local M = {}

function M.setup()
    vim.pack.add { { src = 'https://github.com/saecki/crates.nvim' } }

    require('crates').setup {
        completion = {
            cmp = { enabled = false },
            crates = { enabled = true },
        },
        lsp = { enabled = true },
    }
end

return M
