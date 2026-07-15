-- lua/plugins/lsp/meta/luassert_ext.lua
---@meta

---@class luassert.custom
local custom = {}

---@param expected any
---@param actual any
---@param message? string
function custom.equals(expected, actual, message) end

---@param expected any
---@param actual any
---@param message? string
function custom.same(expected, actual, message) end

---@class luassert: luassert.custom
