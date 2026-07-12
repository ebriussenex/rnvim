local opt = vim.opt

-- ui
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.termguicolors = true
opt.signcolumn = 'yes'
opt.cmdheight = 1
opt.showmode = false
-- -- popups/windows
opt.winminwidth = 5
opt.winblend = 10
opt.pumblend = 10
opt.pumheight = 10
-- --
opt.virtualedit = 'block'
opt.smoothscroll = true
opt.inccommand = 'split'

-- indentation, don't use smartindent, it is for C and only C. And it breaks C, and OCaml, and Haskell, pain in the ass to remember!
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = -1 -- check usr_30.txt
opt.expandtab = true -- Go uses tabs, but it'll not break, i promise
opt.autoindent = true
opt.breakindent = true

-- behaviour
opt.autochdir = false
opt.mouse = 'a'

-- perf, random
opt.synmaxcol = 300 -- syntax hl limit
opt.updatetime = 300
opt.redrawtime = 10000
opt.maxmempattern = 20000
opt.timeoutlen = 400 -- should be good for which-key
opt.ttimeoutlen = 10
opt.autoread = true

-- grep
opt.grepformat = '%f:%l:%c:%m'
opt.grepprg = 'rg --vimgrep'

-- split
vim.opt.splitright = true
vim.opt.splitbelow = true
-- search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- backups
local state = vim.fn.stdpath 'state'
local undodir = state .. '/undo'
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, 'p')
end
opt.undodir = undodir
opt.undofile = true
opt.undolevels = 10000

opt.swapfile = true
opt.directory = state .. '/swap//'
opt.backup = false
opt.writebackup = true
opt.backupdir = state .. '/backup//'

local swap = state .. '/swap'
local backup = state .. '/backup'
if vim.fn.isdirectory(swap) == 0 then
    vim.fn.mkdir(swap, 'p')
end
if vim.fn.isdirectory(backup) == 0 then
    vim.fn.mkdir(backup, 'p')
end
-- ssh clipboard
opt.clipboard = vim.env.SSH_TTY and '' or 'unnamedplus'

-- folding
opt.foldenable = false
opt.fillchars = {
    fold = ' ',
    diff = '╱',
    eob = ' ',
}
