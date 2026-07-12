local map = vim.keymap.set

-- navigation
-- windows
map('n', '<C-h>', '<C-w><C-h>', { desc = 'to left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'to right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'to lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'to upper window' })
-- buffers
map('n', '<leader>bn', ':bnext<CR>', { desc = '[b]uffer [n]ext' })
map('n', '<leader>bp', ':bprevious<CR>', { desc = '[b]uffer [p]rev' })
map('n', '<leader>bb', '<cmd>e #<CR>', { desc = 'last edited [b]uffer' })

-- code movements
-- move lines with alt
map('n', '<A-j>', '<cmd>execute \'move .+\' . v:count1<cr>==', { desc = 'move line down' })
map('n', '<A-k>', '<cmd>execute \'move .-\' . (v:count1 + 1)<cr>==', { desc = 'move line up' })
map('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'move line down' })
map('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'move line up' })
map('v', '<A-j>', ':<C-u>execute "\'<,\'>move \'>+" . v:count1<cr>gv=gv', { desc = 'move line down' })
map('v', '<A-k>', ':<C-u>execute "\'<,\'>move \'<-" . (v:count1 + 1)<cr>gv=gv', { desc = 'move line up' })
map('n', '<left>', '<cmd>arrows disabled<CR>')
map('n', '<right>', '<cmd>arrows disabled<CR>')
map('n', '<up>', '<cmd>arrows disabled<CR>')
map('n', '<down>', '<cmd>arrows disabled<CR>')

-- disable highlight search after find
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- diagnostic keymaps
map('n', '[d', function()
    vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'go to previous [d]iagnostic message' })
map('n', ']d', function()
    vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'go to next [d]iagnostic message' })

map('n', '[e', function()
    vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Prev error' })
map('n', ']e', function()
    vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Next error' })

map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'show diagnostic [e]rror messages' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'open diagnostic [q]uickfix list' })

-- terminal
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'exit terminal mode' })
map('n', '<leader>tt', '<cmd>split | term<cr>', { desc = '[t]erminal horizontal' })
map('n', '<leader>tv', '<cmd>vsplit | term<cr>', { desc = '[t]erminal [v]ertical' })

-- relative number
map('n', '<leader>rr', function()
    if vim.wo.relativenumber then
        vim.wo.relativenumber = false
        vim.wo.number = true
    else
        vim.wo.relativenumber = true
        vim.wo.number = true
    end
end, { desc = 'toggle [r]elative numbe[r]' })
