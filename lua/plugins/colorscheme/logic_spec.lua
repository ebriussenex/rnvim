local logic = require 'plugins.colorscheme.logic'

local schemes = {
    { variants = { { name = 'a1', bg = 'dark' } } },
    { variants = { { name = 'b1', bg = 'light' }, { name = 'b2', bg = 'dark' } }, default = 'b2' },
    { variants = { { name = 'c1', bg = 'light' } } }, -- all-light scheme, edge case
    { variants = { { name = 'd1', bg = 'dark' } } },
}

describe('find_scheme', function()
    it('finds the owning scheme and variant', function()
        local scheme, variant = logic.find_scheme(schemes, 'b1')
        assert.equals(schemes[2], scheme)
        assert(variant ~= nil)
        assert.equals('b1', variant.name)
    end)

    it('returns nil, nil for an unknown name', function()
        local scheme, variant = logic.find_scheme(schemes, 'nope')
        assert.is_nil(scheme)
        assert.is_nil(variant)
    end)
end)

describe('usable_variants', function()
    local variants = {
        { name = 'a', bg = 'dark' },
        { name = 'b', bg = 'light' },
        { name = 'c', bg = 'dark' },
    }

    it('returns everything when transparent is false', function()
        assert.are.same(variants, logic.usable_variants(variants, false))
    end)

    it('returns only dark variants when transparent is true', function()
        local result = logic.usable_variants(variants, true)
        assert.equals(2, #result)
        assert.equals('a', result[1].name)
        assert.equals('c', result[2].name)
    end)

    it('returns EMPTY (no fallback) if none are dark', function()
        local all_light = { { name = 'x', bg = 'light' } }
        assert.equals(0, #logic.usable_variants(all_light, true))
    end)
end)

describe('default_variant', function()
    it('uses variants[1] when no default is set and not transparent', function()
        assert.equals('a1', logic.default_variant(schemes[1], false).name)
    end)

    it('uses the explicit default when usable', function()
        assert.equals('b2', logic.default_variant(schemes[2], false).name)
    end)

    it('falls back to first usable variant if declared default is filtered out', function()
        -- scheme[2]'s default is 'b2' (dark), so this stays 'b2' even transparent — sanity check
        assert.equals('b2', logic.default_variant(schemes[2], true).name)
    end)

    it('returns nil if scheme has no usable variant under transparency', function()
        assert.is_nil(logic.default_variant(schemes[3], true)) -- c1 is light-only
    end)
end)

describe('next_scheme_default', function()
    it('moves forward to the next scheme default (non-transparent)', function()
        assert.equals('b2', logic.next_scheme_default(schemes, 'a1', 1, false).name)
    end)

    it('skips an all-light scheme when transparent=true', function()
        -- from b2 (scheme 2), next would be scheme 3 (all-light) — must skip to scheme 4
        assert.equals('d1', logic.next_scheme_default(schemes, 'b2', 1, true).name)
    end)

    it('moves backward and skips all-light scheme too', function()
        -- from d1 (scheme 4), prev is scheme 3 (all-light, skip) -> scheme 2's default b2
        assert.equals('b2', logic.next_scheme_default(schemes, 'd1', -1, true).name)
    end)

    it('wraps around correctly', function()
        assert.equals('a1', logic.next_scheme_default(schemes, 'd1', 1, false).name)
    end)
end)

describe('step_variant', function()
    local variants = {
        { name = 'x', bg = 'dark' },
        { name = 'y', bg = 'light' },
        { name = 'z', bg = 'dark' },
    }

    it('steps through all variants when not transparent', function()
        assert.equals('y', logic.step_variant(variants, 'x', 1, false).name)
    end)

    it('skips light variants when transparent', function()
        assert.equals('z', logic.step_variant(variants, 'x', 1, true).name)
    end)

    it('restarts from first usable if current variant got filtered out', function()
        -- currently on 'y' (light), but transparent=true means 'y' isn't in the usable list
        assert.equals('x', logic.step_variant(variants, 'y', 1, true).name)
    end)

    it('returns nil if nothing is usable', function()
        local all_light = { { name = 'only', bg = 'light' } }
        assert.is_nil(logic.step_variant(all_light, 'only', 1, true))
    end)
end)

describe('flatten_usable', function()
    it('excludes light variants when transparent=true', function()
        local items = logic.flatten_usable(schemes, true)
        for _, item in ipairs(items) do
            assert.equals('dark', item.variant.bg)
        end
    end)

    it('includes everything when transparent=false', function()
        local items = logic.flatten_usable(schemes, false)
        assert.equals(5, #items) -- a1, b1, b2, c1, d1
    end)
end)
