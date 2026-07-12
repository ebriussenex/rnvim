local function augroup(name)
  return vim.api.nvim_create_augroup('user_' .. name, { clear = true })
end

vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup("highlight"),
  callback = function() vim.highlight.on_yank() end,
})

-- delete whitespace at end when write
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup("trim_whitespace"),
  pattern = '*',
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- set filetype for .env/*.env.* files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("env_filetype"),
  pattern = { "*.env", ".env.*" },
  callback = function()
    vim.opt_local.filetype = "sh"
  end,
})

-- set filetype for .code-snippets
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("code_snippets_filetype"),
  pattern = { "*.code-snippets" },
  callback = function()
    vim.opt_local.filetype = "json"
  end,
})

-- open file with cursor on last edited
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_cursor"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then return end
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
