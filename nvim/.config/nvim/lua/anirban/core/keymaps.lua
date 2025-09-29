-- keybindings. 'noremap' not provided in the opts table since it is assumed to be applied by default.

vim.g.mapleader = " "
vim.g.maplocalleader = "," -- will use these for filetype specific bindings

local keymap = vim.keymap

keymap.set("n", "<leader>bn", "<cmd>bprevious<CR>", { silent = true, desc = "previous buffer" })
keymap.set("n", "<leader>bp", "<cmd>bnext<CR>", { silent = true, desc = "next buffer" })
keymap.set("n", "<leader>an", "<cmd>previous<CR>", { silent = true, desc = "prev arg in arglist" })
keymap.set("n", "<leader>ap", "<cmd>next<CR>", { silent = true, desc = "next arg in arglist" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { silent = true, desc = "increment number" })
keymap.set("n", "<leader>-", "<C-x>", { silent = true, desc = "decrement number" })

-- tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { silent = true, desc = "open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { silent = true, desc = "close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { silent = true, desc = "go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { silent = true, desc = "go to prev tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { silent = true, desc = "open buffer in new tab" })

-- quickfix list mapping
keymap.set("n", "<leader>qn", "<cmd>cnext<CR>", { silent = true, desc = "jump to next qflist item" })
keymap.set("n", "<leader>qp", "<cmd>cprev<CR>", { silent = true, desc = "jump to prev qflist item" })
keymap.set("n", "<leader>qf", "<cmd>cfirst<CR>", { silent = true, desc = "jump to first qflist item" })
keymap.set("n", "<leader>ql", "<cmd>clast<CR>", { silent = true, desc = "jump to last qflist item" })
keymap.set("n", "<leader>qo", "<cmd>copen<CR>", { silent = true, desc = "open qflist window" })
keymap.set("n", "<leader>qx", "<cmd>cclose<CR>", { silent = true, desc = "close qflist window" })
