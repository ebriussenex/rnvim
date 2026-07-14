local M = {}

function M.setup(event)
    local builtin = require 'telescope.builtin'
    local buf = event.buf

    local function map(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { buffer = buf, desc = desc })
    end

    -- navigation
    map('n', 'gd', builtin.lsp_definitions, '[g]oto [d]efinition')
    map('n', 'gr', builtin.lsp_references, '[g]oto [r]eferences')
    map('n', 'gI', builtin.lsp_implementations, '[g]oto [I]mplementation')
    map('n', '<leader>D', builtin.lsp_type_definitions, 'type [D]efinition')
    map('n', '<leader>ds', builtin.lsp_document_symbols, '[d]ocument [s]ymbols')
    map('n', '<leader>ws', builtin.lsp_dynamic_workspace_symbols, '[w]orkspace [s]ymbols')

    --  lsp api
    map('n', 'K', vim.lsp.buf.hover, 'hover documentation')
    map('n', '<leader>rn', vim.lsp.buf.rename, '[r]e[n]ame')
    map({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, 'code [a]ction ')
end

return M
