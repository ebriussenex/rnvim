local M = {}

function M.setup()
    local gh = function(repo)
        return 'https://github.com/' .. repo
    end
    vim.pack.add { { src = gh 'rebelot/heirline.nvim' } }

    local heirline = require 'heirline'
    local utils = require 'heirline.utils'
    local conditions = require 'heirline.conditions'

    local ViMode = {
        init = function(self)
            self.mode = vim.fn.mode(1)
        end,
        static = {
            mode_names = {
                n = 'NORMAL',
                i = 'INSERT',
                v = 'VISUAL',
                V = 'V-LINE',
                ['\22'] = 'V-BLOCK',
                c = 'COMMAND',
                R = 'REPLACE',
                t = 'TERMINAL',
            },
            mode_hl_groups = {
                n = 'Function',
                i = 'String',
                v = 'Constant',
                V = 'Constant',
                ['\22'] = 'Constant',
                c = 'WarningMsg',
                R = 'ErrorMsg',
                t = 'Comment',
            },
        },
        provider = function(self)
            return ' %2(' .. (self.mode_names[self.mode:sub(1, 1)] or self.mode) .. '%) '
        end,
        hl = function(self)
            local group = self.mode_hl_groups[self.mode:sub(1, 1)] or 'Function'
            return { fg = utils.get_highlight(group).fg, bold = true }
        end,
    }

    local FileIcon = {
        init = function(self)
            local filename = vim.fn.expand '%:t'
            local icon, hl_group = require('mini.icons').get('file', filename)
            self.icon, self.icon_hl = icon, hl_group
        end,
        provider = function(self)
            return self.icon and (self.icon .. ' ') or ''
        end,
        hl = function(self)
            return { fg = self.icon_hl and utils.get_highlight(self.icon_hl).fg or nil }
        end,
    }

    local FileName = {
        provider = function()
            local name = vim.fn.expand '%:t'
            return name == '' and '[No Name]' or name
        end,
        hl = function()
            return { fg = utils.get_highlight('Normal').fg }
        end,
    }

    local Git = {
        condition = conditions.is_git_repo,
        init = function(self)
            self.status = vim.b.gitsigns_status_dict
        end,
        provider = function(self)
            return self.status and (' ' .. (self.status.head or '') .. ' ') or ''
        end,
        hl = function()
            return { fg = utils.get_highlight('Constant').fg }
        end,
    }

    local Diagnostics = {
        condition = conditions.has_diagnostics,
        init = function(self)
            self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        end,
        {
            provider = function(self)
                return self.errors > 0 and (' ' .. self.errors .. ' ') or ''
            end,
            hl = function()
                return { fg = utils.get_highlight('DiagnosticError').fg }
            end,
        },
        {
            provider = function(self)
                return self.warnings > 0 and (' ' .. self.warnings .. ' ') or ''
            end,
            hl = function()
                return { fg = utils.get_highlight('DiagnosticWarn').fg }
            end,
        },
    }

    local LspActive = {
        condition = conditions.lsp_attached,
        provider = function()
            local names = {}
            for _, c in pairs(vim.lsp.get_clients { bufnr = 0 }) do
                table.insert(names, c.name)
            end
            return #names > 0 and (' ' .. table.concat(names, ', ') .. ' ') or ''
        end,
        hl = function()
            return { fg = utils.get_highlight('Comment').fg }
        end,
    }

    local Ruler = {
        provider = ' %l:%c  %P ',
        hl = function()
            return { fg = utils.get_highlight('Comment').fg }
        end,
    }

    heirline.setup {
        statusline = {
            ViMode,
            { provider = ' ' },
            FileIcon,
            FileName,
            { provider = ' ' },
            Git,
            { provider = ' ' },
            { provider = '%=' },
            Diagnostics,
            LspActive,
            Ruler,
        },
    }
end

return M
