local logic = require 'plugins.colorscheme.logic'

local M = {}

local STATE_FILE = vim.fn.stdpath 'state' .. '/colorscheme_state.json'

---@type ColorschemeEntry[]
local schemes = {
    {
        src = 'bluz71/vim-moonfly-colors',
        name = 'moonfly',
        module = 'moonfly',
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
                booleans = { italic = false, bold = true },
                comments = { italic = false },
                identifiers = { bold = true },
            },
        },
    },
    {
        src = 'wtfox/jellybeans.nvim',
        module = 'jellybeans',
        default = 'jellybeans',
        variants = {
            { name = 'jellybeans', bg = 'dark' },
            { name = 'jellybeans-light', bg = 'light' },
            { name = 'jellybeans-muted', bg = 'dark' },
            { name = 'jellybeans-muted-light', bg = 'light' },
            { name = 'jellybeans-mono', bg = 'dark' },
            { name = 'jellybeans-mono-light', bg = 'light' },
            { name = 'jellybeans-warm', bg = 'dark' },
            { name = 'jellybeans-hc', bg = 'dark' },
        },
        cfg = { italics = false, plugins = { all = true } },
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
        default = 'kanagawa-paper-ink',
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

---@type { variant: string?, transparent: boolean }
local state = { variant = nil, transparent = false }

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

---Apply state.variant/state.transparent to the actual editor.
---@return nil
local function apply()
    local scheme, variant = logic.find_scheme(schemes, state.variant)
    if not scheme or not variant then
        vim.notify('apply(): unknown variant "' .. tostring(state.variant) .. '", falling back', vim.log.levels.ERROR)
        scheme = schemes[1]
        variant = scheme.variants[1]
        state.variant = variant.name
    end

    if scheme.cfg_apply then
        scheme.cfg_apply(state.transparent)
    else
        local cfg = vim.tbl_deep_extend('force', {}, scheme.cfg or {}, { transparent = state.transparent })
        require(scheme.module).setup(cfg)
    end

    vim.cmd.colorscheme(variant.name)
    force_transparent()
end

---@return nil
function M.setup()
    vim.pack.add(vim.tbl_map(function(s)
        return { src = 'https://github.com/' .. s.src, name = s.name }
    end, schemes))

    load_state()
    if not state.variant then
        state.variant = logic.default_variant(schemes[1], state.transparent).name
    end

    local ok, err = pcall(apply)
    if not ok then
        vim.notify('colorscheme apply failed, falling back: ' .. tostring(err), vim.log.levels.WARN)
        state.variant = logic.default_variant(schemes[1], false).name
        state.transparent = false
        apply()
    end

    vim.api.nvim_create_autocmd({ 'ColorScheme', 'BufWinEnter' }, {
        group = vim.api.nvim_create_augroup('force-transparent', { clear = true }),
        callback = force_transparent,
    })

    vim.keymap.set('n', '<leader>ut', function()
        local _, variant = logic.find_scheme(schemes, state.variant)
        local new_transparent = not state.transparent

        if new_transparent and variant.bg == 'light' then
            vim.notify('Transparency requires a dark variant. Switch to a dark variant first (<leader>uj/<leader>uk).', vim.log.levels.WARN)
            return
        end

        state.transparent = new_transparent
        apply()
        save_state()
        vim.notify('Transparency: ' .. tostring(state.transparent))
    end, { desc = '[U]I toggle [t]ransparency' })

    vim.keymap.set('n', '<leader>ul', function()
        local next_variant = logic.next_scheme_default(schemes, state.variant, 1, state.transparent)
        if next_variant then
            state.variant = next_variant.name
            apply()
            save_state()
            vim.notify('Colorscheme: ' .. next_variant.name)
        else
            vim.notify('No usable scheme in this direction under current transparency', vim.log.levels.WARN)
        end
    end, { desc = '[U]I next scheme' })

    vim.keymap.set('n', '<leader>uh', function()
        local next_variant = logic.next_scheme_default(schemes, state.variant, -1, state.transparent)
        if next_variant then
            state.variant = next_variant.name
            apply()
            save_state()
            vim.notify('Colorscheme: ' .. next_variant.name)
        else
            vim.notify('No usable scheme in this direction under current transparency', vim.log.levels.WARN)
        end
    end, { desc = '[U]I prev scheme' })

    vim.keymap.set('n', '<leader>uk', function()
        local scheme = select(1, logic.find_scheme(schemes, state.variant))
        local next_variant = logic.step_variant(scheme.variants, state.variant, 1, state.transparent)
        if next_variant then
            state.variant = next_variant.name
            apply()
            save_state()
            vim.notify('Variant: ' .. next_variant.name)
        else
            vim.notify('No usable variant in this scheme under current transparency', vim.log.levels.WARN)
        end
    end, { desc = '[U]I next variant' })

    vim.keymap.set('n', '<leader>uj', function()
        local scheme = select(1, logic.find_scheme(schemes, state.variant))
        local next_variant = logic.step_variant(scheme.variants, state.variant, -1, state.transparent)
        if next_variant then
            state.variant = next_variant.name
            apply()
            save_state()
            vim.notify('Variant: ' .. next_variant.name)
        else
            vim.notify('No usable variant in this scheme under current transparency', vim.log.levels.WARN)
        end
    end, { desc = '[U]I prev variant' })
end

return M
