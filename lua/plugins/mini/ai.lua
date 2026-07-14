local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end
    vim.pack.add { { src = gh 'nvim-mini/mini.nvim' } }

    local ai = require 'mini.ai'
    ai.setup {
        n_lines = 500,
        custom_textobjects = {
            a = ai.gen_spec.treesitter { a = '@parameter.outer', i = '@parameter.inner' },
            f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
            c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },
        },
    }
end

return M
