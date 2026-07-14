local M = {}

function M.setup()
    local dap = require 'dap'
    local dapui = require 'dapui'

    dapui.setup()
    require('nvim-dap-virtual-text').setup()

    dap.listeners.before.attach.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
    end

    vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = '[d]ebug Toggle [U]I' })
end

return M
