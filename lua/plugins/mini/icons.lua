local M = {}

function M.setup()
    vim.pack.add { { src = 'https://github.com/nvim-mini/mini.nvim' } }

    require('mini.icons').setup()
    require('mini.icons').mock_nvim_web_devicons()
end

return M
