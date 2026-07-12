local M = {}

local map_lsp = function(event)
    return function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
end

-- local setup_keymaps = function(event)
--     local map = map_lsp(event)
--     map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
--     map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
--     map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
--     map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
--     map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
--     map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
--     map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
--     map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
--     map('K', vim.lsp.buf.hover, 'Hover Documentation')
--     map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
-- end

local hl_on_cursor = function(event, client)
    if client and client:supports_method('textDocument/documentHighlight') then
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

local enable_inlay_hints = function(event, client)
    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
        map_lsp(event)('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, '[t]oggle Inlay [h]ints')
    end
end

 function M.setup()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      -- setup_keymaps(event)
      hl_on_cursor(event, client)
      enable_inlay_hints(event, client)
    end,
  })
end



return M
