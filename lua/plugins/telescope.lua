local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end

    vim.api.nvim_create_autocmd('PackChanged', {
        callback = function(ev)
            if ev.data.spec.name == 'telescope-fzf-native.nvim' and ev.data.kind ~= 'delete' then
                vim.system({ 'make' }, { cwd = ev.data.path }):wait()
            end
        end,
    })

    vim.pack.add {
        { src = gh 'nvim-lua/plenary.nvim' },
        { src = gh 'nvim-telescope/telescope.nvim' },
        { src = gh 'nvim-telescope/telescope-fzf-native.nvim' },
        { src = gh 'nvim-telescope/telescope-ui-select.nvim' },
    }

    local telescope = require 'telescope'
    local themes = require 'telescope.themes'

    telescope.setup {
        defaults = {
            mappings = {
                i = { ['<c-enter>'] = 'to_fuzzy_refine' },
            },
            file_ignore_patterns = {
                '^vendor/',
            },
        },
        pickers = {
            colorscheme = {
                enable_preview = true,
            },
        },
        extensions = {
            ['ui-select'] = {
                themes.get_dropdown(),
            },
        },
    }

    for _, ext in ipairs { 'fzf', 'ui-select' } do
        local ok, err = pcall(telescope.load_extension, ext)
        if not ok then
            vim.notify('telescope: failed to load extension ' .. ext .. ': ' .. tostring(err), vim.log.levels.WARN)
        end
    end

    local builtin = require 'telescope.builtin'

    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[s]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[s]earch [k]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[s]earch [f]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[s]earch [s]elect telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[s]earch current [w]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[s]earch by [g]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[s]earch [d]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[s]earch [r]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[s]earch recent files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'find existing buffers' })

    vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(themes.get_dropdown {
            winblend = 10,
            previewer = false,
        })
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
        }
    end, { desc = '[s]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[s]earch [n]eovim files' })

    vim.keymap.set('n', 'gd', builtin.lsp_definitions, { desc = '[g]oto [d]efinition' })
    vim.keymap.set('n', 'gr', builtin.lsp_references, { desc = '[g]oto [r]eferences' })
    vim.keymap.set('n', 'gI', builtin.lsp_implementations, { desc = '[g]oto [i]mplementation' })
    vim.keymap.set('n', '<leader>D', builtin.lsp_type_definitions, { desc = 'type [d]efinition' })
    vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, { desc = '[d]ocument [s]ymbols' })
    vim.keymap.set('n', '<leader>ws', builtin.lsp_dynamic_workspace_symbols, { desc = '[w]orkspace [s]ymbols' })
end

return M
