local M = {}

local STATE_FILE = vim.fn.stdpath 'state' .. '/colorscheme_state.json'

-- other schemes
-- https://github.com/ramojus/mellifluous.nvim
-- https://github.com/vague-theme/vague.nvim
-- https://github.com/mellow-theme/mellow.nvim
-- https://github.com/nyoom-engineering/oxocarbon.nvim
-- https://github.com/cseelus/vim-colors-lucid

---@class ColorschemeVariant
---@field name string          -- exact string passed to `:colorscheme`
---@field bg 'dark'|'light'     -- used to filter variants when transparency is on

---@class ColorschemeEntry
---@field src string                              -- "owner/repo" for vim.pack.add
---@field name? string                            -- override pack directory name (needed when repo name != colorscheme name, e.g. moonfly)
---@field module? string                          -- lua module name for require(module).setup(cfg); omit if cfg_apply is used instead
---@field variants ColorschemeVariant[]            -- all `:colorscheme` targets this plugin provides
---@field cfg? table                               -- opts table passed to require(module).setup(); merged with { transparent = state.transparent }
---@field cfg_apply? fun(transparent: boolean)      -- alternative to cfg/module for vimscript-style themes using vim.g.* globals (e.g. moonfly)

---@type ColorschemeEntry[]
local schemes = {
    {
        src = 'bluz71/vim-moonfly-colors',
        name = 'moonfly',
        variants = { { name = 'moonfly', bg = 'dark' } },
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
        variants = { { name = 'obscure', bg = 'dark' } },
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
            { name = 'jellybeans', bg = 'dark' },
            { name = 'jellybeans-muted', bg = 'dark' },
            { name = 'jellybeans-mono', bg = 'dark' },
            { name = 'jellybeans-warm', bg = 'dark' },
            { name = 'jellybeans-hc', bg = 'dark' },
            { name = 'jellybeans-muted-light', bg = 'light' },
            { name = 'jellybeans-mono-light', bg = 'light' },
            { name = 'jellybeans-light', bg = 'light' },
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
        variants = { { name = 'vesper', bg = 'dark' } },
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
        variants = {
            { name = 'kanagawa-paper-ink', bg = 'dark' },
            { name = 'kanagawa-paper-canvas', bg = 'light' },
        },
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

---@return nil
local function load_state()
    local ok, content = pcall(vim.fn.readfile, STATE_FILE)
    if ok then
        local decoded = vim.json.decode(table.concat(content, '\n'))
        state = vim.tbl_deep_extend('force', state, decoded)
    end
end

---@return nil
local function save_state()
    vim.fn.writefile({ vim.json.encode(state) }, STATE_FILE)
end

---@return nil
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

---@return nil
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

---@param scheme table
---@return table[]
local function usable_variants(scheme)
    if not state.transparent then
        return scheme.variants
    end
    local dark = vim.tbl_filter(function(v)
        return v.bg == 'dark'
    end, scheme.variants)
    return #dark > 0 and dark or scheme.variants
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
        if state.transparent then
            local scheme = schemes[state.index]
            local current = state.variant or scheme.variants[1].name
            local is_dark = vim.tbl_contains(
                vim.tbl_map(function(v)
                    return v.name
                end, usable_variants(scheme)),
                current
            )
            if not is_dark then
                state.variant = usable_variants(scheme)[1].name
            end
        end
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

    map('n', '<leader>uC', function()
        local pickers = require 'telescope.pickers'
        local finders = require 'telescope.finders'
        local conf = require('telescope.config').values
        local actions = require 'telescope.actions'
        local action_state = require 'telescope.actions.state'

        local original = vim.deepcopy(state)

        local items = {}
        for i, scheme in ipairs(schemes) do
            for _, variant in ipairs(scheme.variants) do
                table.insert(items, { index = i, variant = variant.name })
            end
        end

        local function preview()
            local entry = action_state.get_selected_entry()
            if entry then
                state.index, state.variant = entry.value.index, entry.value.variant
                apply()
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
                    --- static analyzer dont understand dynamic telescope's `transform_mod` method adding
                    ---@diagnostic disable-next-line: undefined-field
                    actions.move_selection_next:enhance { post = preview }
                    --- static analyzer dont understand dynamic telescope's `transform_mod` method adding
                    ---@diagnostic disable-next-line: undefined-field
                    actions.move_selection_previous:enhance { post = preview }

                    actions.select_default:replace(function()
                        preview()
                        save_state()
                        actions.close(prompt_bufnr)
                    end)
                    --- static analyzer dont understand dynamic telescope's `transform_mod` method adding
                    ---@diagnostic disable-next-line: undefined-field
                    actions.close:enhance {
                        pre = function()
                            state = original
                            apply()
                        end,
                    }
                    return true
                end,
            })
            :find()
    end, { desc = '[U]I pick [C]olorscheme' })
end

return M
