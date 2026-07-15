local M = {}

--- Find scheme which has this variant
---@param schemes ColorschemeEntry[]
---@param variant_name string
---@return ColorschemeEntry?, ColorschemeVariant?
function M.find_scheme(schemes, variant_name)
    for _, scheme in ipairs(schemes) do
        for _, variant in ipairs(scheme.variants) do
            if variant.name == variant_name then
                return scheme, variant
            end
        end
    end
    return nil, nil
end

--- Filter 'dark' variants when theme is transparent. Empty when all 'light'
---@param variants ColorschemeVariant[]
---@param transparent boolean
---@return ColorschemeVariant[]
function M.usable_variants(variants, transparent)
    if not transparent then
        return variants
    end
    return vim.tbl_filter(function(v)
        return v.bg == 'dark'
    end, variants)
end

--- For scheme return default variant; If default 'light' in transparent finds first 'dark' variant;
--- Returns nil if no 'dark' variant for this scheme;
---@param scheme ColorschemeEntry
---@param transparent boolean
---@return ColorschemeVariant?
function M.default_variant(scheme, transparent)
    local usable = M.usable_variants(scheme.variants, transparent)
    if #usable == 0 then
        return nil
    end
    local default_name = scheme.default
    if default_name then
        for _, v in ipairs(usable) do
            if v.name == default_name then
                return v
            end
        end
    end
    return usable[1]
end

--- Step in scheme, landing on scheme's default usable variant under current transparency;
--- Skips over schemes that have zero usable variants;
---@param schemes ColorschemeEntry[]
---@param current_variant_name string
---@param direction 1|-1
---@param transparent boolean
---@return ColorschemeVariant? -- nil only if NO scheme has any usable variant
function M.next_scheme_default(schemes, current_variant_name, direction, transparent)
    local current_idx = 1
    for i, scheme in ipairs(schemes) do
        for _, v in ipairs(scheme.variants) do
            if v.name == current_variant_name then
                current_idx = i
            end
        end
    end

    local n = #schemes
    for step = 1, n do
        local idx = ((current_idx - 1 + step * direction) % n) + 1
        local variant = M.default_variant(schemes[idx], transparent)
        if variant then
            return variant
        end
    end
    return nil
end

--- Step to the previous/next VARIANT within the current scheme's variant
--- list, respecting transparency filtering. If current_name itself isn't
--- in the usable list (e.g. you just toggled transparency and were on a
--- light variant), starts from the first usable variant instead of
--- stepping relative to a variant that's no longer valid.
---@param variants ColorschemeVariant[]
---@param current_name string
---@param direction 1|-1
---@param transparent boolean
---@return ColorschemeVariant? -- nil if no variant is usable at all
function M.step_variant(variants, current_name, direction, transparent)
    local usable = M.usable_variants(variants, transparent)
    if #usable == 0 then
        return nil
    end

    local current_idx = nil
    for i, v in ipairs(usable) do
        if v.name == current_name then
            current_idx = i
        end
    end

    if not current_idx then
        return usable[1]
    end

    local n = #usable
    local next_idx = ((current_idx - 1 + direction) % n) + 1
    return usable[next_idx]
end

---@param schemes ColorschemeEntry[]
---@return {scheme: ColorschemeEntry, variant: ColorschemeVariant}[]
function M.flatten(schemes)
    local items = {}
    for _, scheme in ipairs(schemes) do
        for _, variant in ipairs(scheme.variants) do
            table.insert(items, { scheme = scheme, variant = variant })
        end
    end
    return items
end

--- Flatten all schemes into {scheme, variant} pairs, filtered by
--- transparency. Used by the picker so that light variants simply don't
--- appear in the list while transparent=true.
---@param schemes ColorschemeEntry[]
---@param transparent boolean
---@return {scheme: ColorschemeEntry, variant: ColorschemeVariant}[]
function M.flatten_usable(schemes, transparent)
    local items = {}
    for _, scheme in ipairs(schemes) do
        for _, variant in ipairs(M.usable_variants(scheme.variants, transparent)) do
            table.insert(items, { scheme = scheme, variant = variant })
        end
    end
    return items
end

return M
