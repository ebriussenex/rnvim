local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets('rust', {
    s('errenum', {
        t { '#[derive(thiserror::Error, Debug)]', 'pub enum ' },
        i(1, 'MyError'),
        t { ' {', '    #[error("' },
        i(2, 'message'),
        t { '")]', '    ' },
        i(3, 'Variant'),
        t '(#[from] ',
        i(4, 'std::io::Error'),
        t { '),', '}' },
    }),
})
