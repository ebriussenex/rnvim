local M = {}

function M.setup()
    require('dap-go').setup {
        delve = {
            detached = vim.fn.has 'win32' == 0,
        },
    }
end

return M
