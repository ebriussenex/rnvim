local M = {}

local hl_on_cursor = function(event, client)
    if client and client:supports_method 'textDocument/documentHighlight' then
        local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
            callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
            end,
        })
    end
end

local function enable_inlay_hints(event, client)
    if client and client:supports_method 'textDocument/inlayHint' then
        vim.keymap.set('n', '<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, { buffer = event.buf, desc = '[T]oggle inlay [h]ints' })
    end
end

function M.setup()
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
        callback = function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            require('plugins.lsp.keymaps').setup(event)
            hl_on_cursor(event, client)
            enable_inlay_hints(event, client)
        end,
    })
end

return M
