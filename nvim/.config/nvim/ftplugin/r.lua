vim.b.slime_cell_delimiter = "#\\s\\=%%"

-- send entire current buffer to REPL
local function slime_send_buffer()
	vim.cmd("normal! ggVG")
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>SlimeRegionSend", true, true, true), "n", false)
end

local function new_terminal(lang)
	-- vim.cmd("vsplit term://" .. lang)
	vim.cmd("silent !tmux splitw -h " .. lang .. " &")
	-- vim.fn.jobstart({ "tmux", "splitw -h " .. lang }, { detach = true })
end

local function new_terminal_r()
	new_terminal("R --quiet")
end

-- open new terminal
vim.keymap.set("n", "<localleader>nr", new_terminal_r, { silent = true, desc = "new R terminal" })

-- send current line
vim.keymap.set("n", "<localleader>rl", "<Plug>SlimeLineSend", { buffer = true, desc = "[r] send current [l]ine" })

-- send selected region (visual mode)
vim.keymap.set("x", "<localleader>rr", "<Plug>SlimeRegionSend", { buffer = true, desc = "[r] send selected [r]egion" })

-- send entire file
vim.keymap.set("n", "<localleader>rf", slime_send_buffer, { buffer = true, desc = "[r] send entire [f]ile" })
