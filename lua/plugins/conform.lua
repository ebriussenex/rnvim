local M = {}

function M.setup()
    vim.pack.add { { src = 'https://github.com/stevearc/conform.nvim' } }

    require('conform').setup {
        notify_on_error = false,
        format_on_save = function(bufnr)
            -- disable lsp fallback for cpp/c when it cant use clang-format
            local disable_filetypes = { c = true, cpp = true }
            return {
                timeout_ms = 500,
                lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
            }
        end,
        formatters_by_ft = {
            lua = { 'stylua' },
            c = { 'clang-format' },
            cpp = { 'clang-format' },
            ocaml = { 'ocamlformat' },
            sql = { 'pg_format' },
        },
        formatters = {
            ocamlformat = {
                prepend_args = {
                    '--if-then-else',
                    'vertical',
                    '--break-cases',
                    'fit-or-vertical',
                    '--type-decl',
                    'sparse',
                },
            },
        },
    }

    vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
        require('conform').format { async = true, lsp_fallback = true }
    end, { desc = '[f]ormat buffer' })
end

return M
