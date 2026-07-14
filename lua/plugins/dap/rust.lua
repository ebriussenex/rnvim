local M = {}

function M.setup()
    local dap = require 'dap'
    local mason_registry = require 'mason-registry'

    local codelldb_path = mason_registry.get_package('codelldb'):get_install_path() .. '/extension/adapter/codelldb'

    dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
            command = codelldb_path,
            args = { '--port', '${port}' },
        },
    }

    dap.configurations.rust = {
        {
            name = 'Launch',
            type = 'codelldb',
            request = 'launch',
            program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
            end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
            args = {},
            showDisassembly = 'never',
            sourceLanguages = { 'rust' },
        },
    }
end

return M
