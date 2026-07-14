local M = {}

local STATE_FILE = vim.fn.stdpath 'state' .. '/colorscheme_state.json'

-- in case there is no file yet
local state = {
    scheme = 'moonfly',
    transparent = false,
    italic = true,
    bold = true,
}

-- other schemes
-- https://github.com/ramojus/mellifluous.nvim
-- https://github.com/vague-theme/vague.nvim
-- https://github.com/mellow-theme/mellow.nvim
-- https://github.com/nyoom-engineering/oxocarbon.nvim
-- https://github.com/cseelus/vim-colors-lucid
-- TODO: get those schemes and make all statements be bold >_<
-- all schemes must be with cfg.tansparent field or have cfg_apply with apply(transparent) (vimrc style) to work properly
local schemes = {
    { -- do not transparent ?
        src = 'bluz71/vim-moonfly-colors',
        name = 'moonfly',
        colorscheme = 'moonfly',
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
        colorscheme = 'obscure',
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
        colorscheme = 'jellybeans',
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
        colorscheme = 'vesper',
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
    { -- TODO: neotree not transparent
        src = 'thesimonho/kanagawa-paper.nvim',
        module = 'kanagawa-paper',
        colorscheme = 'kanagawa-paper-ink',
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

local function apply()
    local scheme = schemes[state.index]
    if scheme.cfg_apply then
        scheme.cfg_apply(state.transparent)
    else
        local cfg = vim.tbl_deep_extend('force', {}, scheme.cfg or {}, { transparent = state.transparent })
        require(scheme.module).setup(cfg)
    end
    vim.cmd.colorscheme(scheme.colorscheme)
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

    vim.keymap.set('n', '<leader>ut', function()
        state.transparent = not state.transparent
        apply()
        save_state()
    end, { desc = '[U]I toggle [t]ransparency' })

    vim.keymap.set('n', '<leader>uc', function()
        state.index = (state.index % #schemes) + 1
        apply()
        save_state()
        vim.notify('Colorscheme: ' .. schemes[state.index].colorscheme)
    end, { desc = '[U]I cycle [c]olorscheme' })
end

return M
