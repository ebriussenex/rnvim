local config = {
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = { globals = { 'vim' } },
            workspace = {
                preloadFileSize = 10000,
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                },
            },
        },
    },
}

vim.lsp.config('lua_ls', config)
