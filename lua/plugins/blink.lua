local M = {}

function M.setup()
    vim.pack.add {
        { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '^1' },
    }

    require('luasnip.loaders.from_vscode').lazy_load()

    require('blink.cmp').setup {
        keymap = {
            preset = 'none',
            ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
            ['<C-e>'] = { 'hide', 'fallback' },
            ['<CR>'] = { 'accept', 'fallback' },
            ['<Tab>'] = { 'select_next', 'fallback' },
            ['<S-Tab>'] = { 'select_prev', 'fallback' },
            ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
            ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
            ['<C-l>'] = { 'snippet_forward', 'fallback' },
            ['<C-h>'] = { 'snippet_backward', 'fallback' },
        },

        snippets = { preset = 'luasnip' },

        completion = {
            documentation = { auto_show = true },
            menu = {
                border = 'rounded',
            },
            list = { selection = { preselect = false } },
        },

        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
            providers = {
                lazydev = {
                    name = 'LazyDev',
                    module = 'lazydev.integrations.blink',
                    score_offset = 100,
                },
            },
        },

        appearance = {
            nerd_font_variant = 'mono',
        },
    }
end

return M
