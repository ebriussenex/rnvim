-- parse --> autocmp --> lsp --> other
require('plugins.treesitter').setup()
require('plugins.mini.ai').setup() -- after treesitter
require('plugins.snippets').setup()
require('plugins.blink').setup()
require 'plugins.lsp'
require('plugins.conform').setup()

require('plugins.dap').setup()

require('plugins.telescope').setup()
require('plugins.todo-comments').setup()
require('plugins.neotree').setup()

require('plugins.colorscheme').setup()
require('plugins.whichkey').setup()
require('plugins.snacks').setup()
require('plugins.gitsigns').setup()
require('plugins.diffview').setup()
require('plugins.heirline').setup() -- after gitsigns

-- no order
require('plugins.autopairs').setup()
