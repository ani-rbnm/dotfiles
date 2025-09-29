return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local todo_comments = require('todo-comments')

    -- HACK: Sample hack todo
    -- BUG: Sample bug todo
    -- TODO: Sample todo
    -- We can search for the above in telescope with <leader>tf as indicated in telescope.lua
    
    -- set keymaps
    local keymap = vim.keymap

    keymap.set('n', ']t', function()
      todo_comments.jump_next()
    end, { desc = 'Next todo comment' })

    keymap.set('n', '[t', function()
      todo_comments.jump_prev()
    end, { desc = 'Prev todo comment' })

    todo_comments.setup()
  end,
}
