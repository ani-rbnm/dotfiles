-- R ftplugin: tmux+slime workflow + quick object introspection helpers
-- Drop-in file for: after/ftplugin/r.lua

-- Use %% cells (your existing setting)
vim.b.slime_cell_delimiter = "#\\s\\=%%"

---------------------------------------------------------------------
-- Existing helpers: send entire buffer / open tmux split
---------------------------------------------------------------------
local function slime_send_buffer()
	vim.cmd("normal! ggVG")
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>SlimeRegionSend", true, true, true), "n", false)
end

local function new_terminal(lang)
	vim.cmd("silent !tmux splitw -h " .. lang .. " &")
end

local function new_terminal_r()
	new_terminal("R --no-save")
end

-- open new terminal
vim.keymap.set("n", "<localleader>nr", new_terminal_r, {
	silent = true,
	buffer = true,
	desc = "new R terminal",
})

-- send current line
vim.keymap.set("n", "<localleader>rl", "<Plug>SlimeLineSend", {
	buffer = true,
	desc = "[r] send current [l]ine",
})

-- send selected region (visual mode)
vim.keymap.set("x", "<localleader>rr", "<Plug>SlimeRegionSend", {
	buffer = true,
	desc = "[r] send selected [r]egion",
})

-- send entire file
vim.keymap.set("n", "<localleader>rf", slime_send_buffer, {
	buffer = true,
	desc = "[r] send entire [f]ile",
})

---------------------------------------------------------------------
-- NEW: send a one-liner to R via slime without selecting anything
---------------------------------------------------------------------
-- Send a single R command via slime (robust: uses SlimeLineSend)
local function slime_send_line(text)
	local bufnr = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local orig = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""

	-- Put the command on the current line
	vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { text })

	-- Send via slime
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>SlimeLineSend", true, true, true), "n", false)

	-- Restore the original line *after* slime has had time to read it
	vim.defer_fn(function()
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { orig })
		end
	end, 50) -- 50ms is usually plenty; bump to 100 if needed
end

-- Robust R object under cursor:
-- handles df, (df), df$a, df[[1]], df@slot, etc.
local function cword()
	local w = vim.fn.expand("<cWORD>")

	-- strip surrounding parentheses repeatedly: ((df)) -> df
	while w:match("^%b()$") do
		w = w:sub(2, -2)
	end

	-- strip common R accessors
	w = w
		:gsub("%$.*$", "") -- df$col
		:gsub("@.*$", "") -- df@slot
		:gsub("%[%[.*$", "") -- df[[1]]
		:gsub("%[.*$", "") -- df[1]

	-- final trim (defensive)
	w = w:gsub("^%s+", ""):gsub("%s+$", "")

	return w
end

---------------------------------------------------------------------
-- NEW: object introspection (runtime "object awareness")
---------------------------------------------------------------------
vim.keymap.set("n", "<localleader>rn", function()
	slime_send_line(("names(%s)"):format(cword()))
end, { buffer = true, desc = "R: names(<cword>)" })

vim.keymap.set("n", "<localleader>rs", function()
	slime_send_line(("str(%s, max.level = 1)"):format(cword()))
end, { buffer = true, desc = "R: str(<cword>) shallow" })

vim.keymap.set("n", "<localleader>ra", function()
	slime_send_line(("args(%s)"):format(cword()))
end, { buffer = true, desc = "R: args(<cword>)" })

vim.keymap.set("n", "<localleader>rm", function()
	local w = cword()
	slime_send_line(("methods(class = class(%s)[1])"):format(w))
end, { buffer = true, desc = "R: methods for class(<cword>)" })

vim.keymap.set("n", "<localleader>rS", function()
	local w = cword()
	slime_send_line(("if (isS4(%s)) slotNames(%s) else 'not S4'"):format(w, w))
end, { buffer = true, desc = "R: slotNames(<cword>) if S4" })

---------------------------------------------------------------------
-- NEW (optional): make cmp buffer completion kick in earlier for R
---------------------------------------------------------------------
local ok, cmp = pcall(require, "cmp")
if ok then
	cmp.setup.buffer({
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "buffer", keyword_length = 2 }, -- global was 5
			{ name = "spell" },
			{ name = "path" },
		}),
	})
end
