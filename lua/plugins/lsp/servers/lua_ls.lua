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
            },
        },
    },
}

vim.lsp.config('lua_ls', config)
