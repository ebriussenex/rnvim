local M = {}

function M.setup()
    vim.pack.add { { src = 'https://github.com/windwp/nvim-autopairs' } }

    require('nvim-autopairs').setup {
        check_ts = true,
        disable_filetype = { 'TelescopePrompt' },
    }
end

return M
