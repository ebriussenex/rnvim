-- parse --> autocmp --> lsp --> other
require('plugins.treesitter').setup()
require('plugins.snippets').setup()
require('plugins.blink').setup()
require 'plugins.lsp'
require('plugins.conform').setup()

require('plugins.icons').setup()
require('plugins.telescope').setup()
require('plugins.neotree').setup()

require('plugins.colorscheme').setup()
require('plugins.whichkey').setup()

-- no order
require('plugins.autopairs').setup()
