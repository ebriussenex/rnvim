local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end
    vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter-textobjects', version = 'main' } }

    require('nvim-treesitter-textobjects').setup {
        move = { set_jumps = true },
    }

    local move = require 'nvim-treesitter-textobjects.move'
    local map = vim.keymap.set

    map({ 'n', 'x', 'o' }, ']m', function()
        move.goto_next_start('@function.outer', 'textobjects')
    end, { desc = 'Next function start' })
    map({ 'n', 'x', 'o' }, '[m', function()
        move.goto_previous_start('@function.outer', 'textobjects')
    end, { desc = 'Prev function start' })
    map({ 'n', 'x', 'o' }, ']]', function()
        move.goto_next_start('@class.outer', 'textobjects')
    end, { desc = 'Next class start' })
    map({ 'n', 'x', 'o' }, '[[', function()
        move.goto_previous_start('@class.outer', 'textobjects')
    end, { desc = 'Prev class start' })
end

return M
