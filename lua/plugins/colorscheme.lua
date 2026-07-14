local M = {}

local STATE_FILE = vim.fn.stdpath 'state' .. '/colorscheme_state.json'

-- other schemes
-- https://github.com/ramojus/mellifluous.nvim
-- https://github.com/vague-theme/vague.nvim
-- https://github.com/mellow-theme/mellow.nvim
-- https://github.com/nyoom-engineering/oxocarbon.nvim
-- https://github.com/cseelus/vim-colors-lucid
-- TODO: get those schemes and make all statements be bold >_<
-- NOTE: all schemes must be with cfg.tansparent field or have cfg_apply with apply(transparent) (vimrc style) to work properly
local schemes = {
    {
        src = 'bluz71/vim-moonfly-colors',
        name = 'moonfly',
        variants = { 'moonfly' },
        cfg_apply = function(transparent)
            vim.g.moonflyCursorColor = true
            vim.g.moonflyItalics = false
            vim.g.moonflyNormalFloat = true
            vim.g.moonflyTransparent = transparent
            vim.g.moonflyUnderlineMatchParen = true
            vim.g.moonflyVirtualTextColor = true
        end,
    },
    {
        src = 'killitar/obscure.nvim',
        module = 'obscure',
        variants = { 'obscure' },
        cfg = {
            styles = {
                booleans = {
                    italic = false,
                    bold = true,
                },
                comments = {
                    italic = false,
                },
                identifiers = {
                    bold = true,
                },
            },
        },
    },
    {
        src = 'wtfox/jellybeans.nvim',
        module = 'jellybeans',
        variants = {
            'jellybeans',
            'jellybeans-light',
            'jellybeans-muted',
            'jellybeans-muted-light',
            'jellybeans-mono',
            'jellybeans-mono-light',
            'jellybeans-warm',
            'jellybeans-hc',
        },
        cfg = {
            italics = false,
            plugins = {
                all = true, -- there is auto = true, which will work with lazy.nvim
            },
        },
    },
    {
        src = 'datsfilipe/vesper.nvim',
        module = 'vesper',
        variants = { 'vesper' },
        cfg = {
            italics = {
                comments = false,
                keywords = false,
                functions = false,
                strings = false,
                variables = false,
            },
        },
    },
    {
        src = 'thesimonho/kanagawa-paper.nvim',
        module = 'kanagawa-paper',
        variants = { 'kanagawa-paper-ink', 'kanagawa-paper-canvas' },
        cfg = {
            cache = true,
            styles = {
                comment = { italic = false },
                functions = { italic = false },
                keyword = { italic = false, bold = true },
                statement = { italic = false, bold = true },
                type = { italic = false },
            },
            all_plugins = true,
            dim_inactive = false,
        },
    },
}

local TRANSPARENT_GROUPS = {
    'Normal',
    'NormalNC',
    'NormalFloat',
    'FloatBorder',
    'SignColumn',
    'TelescopeNormal',
    'TelescopeBorder',
    'TelescopePromptNormal',
    'TelescopePromptBorder',
    'TelescopeResultsNormal',
    'TelescopeResultsBorder',
    'TelescopePreviewNormal',
    'TelescopePreviewBorder',
    'NeoTreeNormal',
    'NeoTreeNormalNC',
    'NeoTreeFloatNormal',
    'NeoTreeFloatBorder',
    'WhichKeyFloat',
}

local state = {
    scheme = 'moonfly',
    transparent = false,
    italic = true,
    bold = true,
}

local function load_state()
    local ok, content = pcall(vim.fn.readfile, STATE_FILE)
    if ok then
        local decoded = vim.json.decode(table.concat(content, '\n'))
        state = vim.tbl_deep_extend('force', state, decoded)
    end
end

local function save_state()
    vim.fn.writefile({ vim.json.encode(state) }, STATE_FILE)
end

local function force_transparent()
    if not state.transparent then
        return
    end
    for _, group in ipairs(TRANSPARENT_GROUPS) do
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        if ok then
            hl.bg = nil
            pcall(vim.api.nvim_set_hl, 0, group, hl)
        end
    end
end

local function apply()
    local scheme = schemes[state.index]
    local variant = state.variant or scheme.variants[1]

    if scheme.cfg_apply then
        scheme.cfg_apply(state.transparent)
    else
        local cfg = vim.tbl_deep_extend('force', {}, scheme.cfg or {}, { transparent = state.transparent })
        require(scheme.module).setup(cfg)
    end

    vim.cmd.colorscheme(variant)
    force_transparent()
end

function M.setup()
    vim.pack.add(vim.tbl_map(function(s)
        return { src = 'https://github.com/' .. s.src, name = s.name }
    end, schemes))

    load_state()

    local ok = pcall(apply)
    if not ok then
        state.index = 1 -- if index broken or scheme deleted - rollback
        apply()
    end

    local map = vim.keymap.set

    map('n', '<leader>ut', function()
        state.transparent = not state.transparent
        apply()
        save_state()
    end, { desc = '[U]I toggle [t]ransparency' })

    map('n', '<leader>uc', function()
        state.index = (state.index % #schemes) + 1
        state.variant = nil
        apply()
        save_state()
        vim.notify('Colorscheme: ' .. schemes[state.index].variants[1])
    end, { desc = '[U]I cycle [c]olorscheme' })

    map('n', '<leader>uv', function()
        local scheme = schemes[state.index]
        local variants = scheme.variants
        local current_idx = 1
        for i, v in ipairs(variants) do
            if v == (state.variant or variants[1]) then
                current_idx = i
            end
        end
        state.variant = variants[(current_idx % #variants) + 1]
        apply()
        save_state()
        vim.notify('Variant: ' .. state.variant)
    end, { desc = '[U]I cycle [v]ariant' })

    vim.keymap.set('n', '<leader>uC', function()
        local pickers = require 'telescope.pickers'
        local finders = require 'telescope.finders'
        local conf = require('telescope.config').values
        local actions = require 'telescope.actions'
        local action_state = require 'telescope.actions.state'

        local items = {}
        for i, scheme in ipairs(schemes) do
            for _, variant in ipairs(scheme.variants) do
                table.insert(items, { index = i, variant = variant })
            end
        end

        pickers
            .new({}, {
                prompt_title = 'Colorschemes',
                finder = finders.new_table {
                    results = items,
                    entry_maker = function(entry)
                        return { value = entry, display = entry.variant, ordinal = entry.variant }
                    end,
                },
                sorter = conf.generic_sorter {},
                attach_mappings = function(prompt_bufnr)
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)
                        state.index = selection.value.index
                        state.variant = selection.value.variant
                        apply()
                        save_state()
                    end)
                    return true
                end,
            })
            :find()
    end, { desc = '[U]I pick [C]olorscheme' })
end

return M
