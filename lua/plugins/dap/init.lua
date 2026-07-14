local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end

    vim.pack.add {
        { src = gh 'mfussenegger/nvim-dap' },
        { src = gh 'rcarriga/nvim-dap-ui' },
        { src = gh 'theHamsta/nvim-dap-virtual-text' },
        { src = gh 'nvim-neotest/nvim-nio' },
        { src = gh 'leoluz/nvim-dap-go' },
        { src = gh 'jay-babu/mason-nvim-dap.nvim' },
    }

    require('mason-nvim-dap').setup {
        ensure_installed = { 'codelldb', 'delve' },
        automatic_installation = true,
    }

    require('plugins.dap.ui').setup()
    require('plugins.dap.rust').setup()
    require('plugins.dap.go').setup()

    local dap = require 'dap'

    -- ui
    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError' })
    vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticWarn', linehl = 'Visual' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn' })

    -- breakpoints
    vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = '[d]ebug toggle [b]reakpoint' })
    vim.keymap.set('n', '<leader>dB', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = '[d]ebug conditional [B]reakpoint' })
    vim.keymap.set('n', '<leader>dC', dap.clear_breakpoints, { desc = '[d]ebug [C]lear all breakpoints' })

    -- control
    vim.keymap.set('n', '<leader>dc', dap.continue, { desc = '[d]ebug [c]ontinue' })
    vim.keymap.set('n', '<leader>di', dap.step_into, { desc = '[d]ebug step [i]nto' })
    vim.keymap.set('n', '<leader>do', dap.step_over, { desc = '[d]ebug step [o]ver' })
    vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = '[d]ebug step [O]ut' })
    vim.keymap.set('n', '<leader>dR', dap.repl.open, { desc = '[d]ebug open [R]epl' })
    vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = '[d]ebug Run [l]ast' })
    vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = '[d]ebug [t]erminate' })
    vim.keymap.set('n', '<leader>dr', dap.run_to_cursor, { desc = '[d]ebug [r]un to cursor' })
    vim.keymap.set('n', '<leader>dL', function()
        dap.set_breakpoint(nil, nil, vim.fn.input 'Log message: ')
    end, { desc = '[d]ebug [L]ogpoint' })

    -- view
    vim.keymap.set({ 'n', 'v' }, '<leader>dh', function()
        local widgets = require 'dap.ui.widgets'
        local widget = widgets.hover()
        local close = function()
            vim.api.nvim_win_close(widgets.win, true)
        end
        vim.keymap.set('n', '<Esc>', close, { buffer = widget.buf })
        vim.keymap.set('n', 'q', close, { buffer = widget.buf })
    end, { desc = '[d]ebug [h]over variable' })
    vim.keymap.set({ 'n', 'v' }, '<leader>dw', function()
        require('dapui').elements.watches.add()
    end, { desc = '[d]ebug Add [w]atch' })
end

return M
