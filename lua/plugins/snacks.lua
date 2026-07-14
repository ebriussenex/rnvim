local M = {}

local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

local snacks = {}

snacks.input = { cfg = { enabled = true } }
snacks.indent = {
    cfg = {
        enabled = true,
        animate = {
            enabled = false,
        },
        indent = {
            char = '│',
            only_scope = false,
            only_current = false,
        },
        scope = {
            enabled = true,
            char = '│',
            underline = false,
        },
    },
    keymaps = function()
        map('n', '<leader>ui', function()
            local snacks_indent = require('snacks').indent
            if snacks_indent.enabled then
                snacks_indent.disable()
            else
                snacks_indent.enable()
            end
        end, '[U]I toggle [i]ndent guides')
    end,
}

snacks.notifier = {
    cfg = {
        enabled = true,
        timeout = 3000,
        style = 'minimal',
    },
    keymaps = function()
        map('n', '<leader>uh', function()
            require('snacks').notifier.show_history()
        end, '[U]I notification [h]istory')
    end,
}

snacks.terminal = {
    cfg = { enabled = true },
    keymaps = function()
        local function term(position)
            return function()
                require('snacks').terminal.toggle(nil, {
                    win = { position = position },
                    env = { SNACKS_TERM_POS = position },
                })
            end
        end

        map({ 'n', 't' }, '<leader>tt', term 'float', '[T]erminal [f]loat')
        map({ 'n', 't' }, '<leader>t-', term 'bottom', '[T]erminal [h]orizontal')
        map({ 'n', 't' }, '<leader>t_', term 'right', '[T]erminal [v]ertical')
    end,
}

snacks.gitbrowse = {
    cfg = { enabled = true },
    keymaps = function()
        map({ 'n', 'v' }, '<leader>ho', function()
            require('snacks').gitbrowse()
        end, 'git [o]pen in browser')
    end,
}

snacks.bigfile = { cfg = { enabled = true } }
snacks.quickfile = { cfg = { enabled = true } }

-- explicitly
snacks.scroll = { cfg = { enabled = false } }
snacks.picker = { cfg = { enabled = false } }
snacks.explorer = { cfg = { enabled = false } }
snacks.words = { cfg = { enabled = false } }
snacks.statuscolumn = { cfg = { enabled = false } }
snacks.dashboard = { cfg = { enabled = false } }
snacks.scratch = { cfg = { enabled = false } }
snacks.zen = { cfg = { enabled = false } }

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end
    vim.pack.add { { src = gh 'folke/snacks.nvim' } }
    local config = {}
    for name, mod in pairs(snacks) do
        config[name] = mod.cfg
    end
    require('snacks').setup(config)

    for _, mod in pairs(snacks) do
        if mod.cfg.enabled and mod.keymaps then
            mod.keymaps()
        end
    end
end
return M
