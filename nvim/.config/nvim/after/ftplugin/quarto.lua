-- ~/.config/nvim/after/ftplugin/quarto.lua
-- User overrides for Quarto buffers (runs after plugin/runtime ftplugins)

local quarto = require("quarto")
local runner = require("quarto.runner")

-- Helpful for vim-slime cell motions; plugin sets this too, harmless here.
vim.b.slime_cell_delimiter = "```"

-- Keep this initialized; slime override checks it
vim.b.quarto_is_python_chunk = vim.b.quarto_is_python_chunk or false

---------------------------------------------------------------------
-- Chunk helpers (quarto-nvim doesn't expose these)
---------------------------------------------------------------------
local function is_code_chunk()
	local current = require("otter.keeper").get_current_language_context()
	return current ~= nil
end

local function current_chunk_lang()
	local ctx = require("otter.keeper").get_current_language_context()
	-- Depending on otter version, ctx might be a string or a table.
	if ctx == nil then
		return nil
	end
	if type(ctx) == "string" then
		return ctx
	end
	if type(ctx) == "table" then
		return ctx.language or ctx.lang or ctx.filetype
	end
	return nil
end

local function in_r_chunk()
	local lang = current_chunk_lang()
	-- otter sometimes returns "r" or "R"
	return lang ~= nil and lang:lower() == "r"
end

local function insert_code_chunk(lang)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)

	local keys
	if is_code_chunk() then
		keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
	else
		keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
	end

	keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end

local function insert_r_chunk()
	insert_code_chunk("r")
end
local function insert_py_chunk()
	insert_code_chunk("python")
end
local function insert_rust_chunk()
	insert_code_chunk("rust")
end

---------------------------------------------------------------------
-- tmux helpers (unchanged)
---------------------------------------------------------------------
local function new_terminal(cmd)
	vim.cmd("silent !tmux splitw -h " .. cmd .. " &")
end

local function new_terminal_python()
	new_terminal("python")
end

local function new_terminal_r()
	new_terminal("R --no-save")
end

-- Launching ipython terminal logic.
local function new_terminal_ipython()
	local cwd = vim.fn.getcwd()

	-- 1) Preferred: per-project venv
	local venv_ipy = cwd .. "/.venv/bin/ipython"
	if vim.fn.executable(venv_ipy) == 1 then
		new_terminal(venv_ipy .. " -i --no-confirm-exit")
		return
	end

	-- 2) Poetry-aware fallback
	local has_pyproject = (vim.fn.filereadable(cwd .. "/pyproject.toml") == 1)
	if has_pyproject and (vim.fn.executable("poetry") == 1) then
		new_terminal("poetry run ipython -i --no-confirm-exit")
		return
	end

	-- 3) Last resort: ipython on PATH
	if vim.fn.executable("ipython") == 1 then
		new_terminal("ipython -i --no-confirm-exit")
		return
	end

	vim.notify(
		"ipython not found. Expected .venv/bin/ipython. (Poetry fallback also unavailable.)",
		vim.log.levels.WARN
	)
end

---------------------------------------------------------------------
-- NEW: slime one-liner sender + R introspection (R chunks only)
---------------------------------------------------------------------
-- Send a single command via slime (uses SlimeLineSend, restores after a tiny delay)
local function slime_send_line(text)
	local bufnr = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local orig = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""

	-- Put the command on the current line
	vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { text })

	-- Send via slime
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>SlimeLineSend", true, true, true), "n", false)

	-- Restore original line after slime has read it
	vim.defer_fn(function()
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { orig })
		end
	end, 50) -- bump to 100 if your tmux/slime is slower
end

-- Robust R object under cursor: df, (df), df$a, (df)$a, df[[1]], df@slot, etc.
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

	-- defensive trim
	w = w:gsub("^%s+", ""):gsub("%s+$", "")
	return w
end

local function r_only(fn)
	return function(...)
		if not in_r_chunk() then
			vim.notify("Not in an R chunk", vim.log.levels.INFO)
			return
		end
		return fn(...)
	end
end

---------------------------------------------------------------------
-- Buffer-local maps so plugin updates won't stomp them
---------------------------------------------------------------------
local mapopts = { buffer = true, silent = true }

-- Preview
vim.keymap.set(
	"n",
	"<localleader>qp",
	quarto.quartoPreview,
	vim.tbl_extend("force", mapopts, { desc = "quarto - preview" })
)
vim.keymap.set(
	"n",
	"<localleader>qP",
	quarto.quartoPreviewNoWatch,
	vim.tbl_extend("force", mapopts, { desc = "quarto - preview (no watch)" })
)
vim.keymap.set(
	"n",
	"<localleader>qu",
	quarto.quartoUpdatePreview,
	vim.tbl_extend("force", mapopts, { desc = "quarto - update preview" })
)

-- Insert chunks
vim.keymap.set(
	"n",
	"<localleader>ip",
	insert_py_chunk,
	vim.tbl_extend("force", mapopts, { desc = "quarto - insert python chunk" })
)
vim.keymap.set(
	"n",
	"<localleader>ir",
	insert_r_chunk,
	vim.tbl_extend("force", mapopts, { desc = "quarto - insert r chunk" })
)
vim.keymap.set(
	"n",
	"<localleader>iu",
	insert_rust_chunk,
	vim.tbl_extend("force", mapopts, { desc = "quarto - insert rust chunk" })
)

-- New terminals
vim.keymap.set(
	"n",
	"<localleader>ni",
	new_terminal_ipython,
	vim.tbl_extend("force", mapopts, { desc = "quarto - new IPython terminal" })
)
vim.keymap.set(
	"n",
	"<localleader>np",
	new_terminal_python,
	vim.tbl_extend("force", mapopts, { desc = "quarto - new Python terminal" })
)
vim.keymap.set(
	"n",
	"<localleader>nr",
	new_terminal_r,
	vim.tbl_extend("force", mapopts, { desc = "quarto - new R terminal" })
)

-- Runner (this is the “new architecture” execution path)
vim.keymap.set(
	"n",
	"<localleader><cr>",
	runner.run_cell,
	vim.tbl_extend("force", mapopts, { desc = "quarto - run cell" })
)
vim.keymap.set(
	"x",
	"<localleader><cr>",
	runner.run_range,
	vim.tbl_extend("force", mapopts, { desc = "quarto - run range" })
)

-- Optional quality-of-life runner maps
vim.keymap.set(
	"n",
	"<localleader>rl",
	runner.run_line,
	vim.tbl_extend("force", mapopts, { desc = "quarto - run line" })
)
vim.keymap.set(
	"n",
	"<localleader>ra",
	runner.run_above,
	vim.tbl_extend("force", mapopts, { desc = "quarto - run above" })
)
vim.keymap.set(
	"n",
	"<localleader>rb",
	runner.run_below,
	vim.tbl_extend("force", mapopts, { desc = "quarto - run below" })
)
vim.keymap.set("n", "<localleader>rA", runner.run_all, vim.tbl_extend("force", mapopts, { desc = "quarto - run all" }))

---------------------------------------------------------------------
-- NEW: R introspection maps (only active inside R chunks)
-- These intentionally do NOT override your runner maps.
---------------------------------------------------------------------
vim.keymap.set(
	"n",
	"<localleader>cn",
	r_only(function()
		slime_send_line(("names(%s)"):format(cword()))
	end),
	vim.tbl_extend("force", mapopts, { desc = "R chunk: names(<cword>)" })
)

vim.keymap.set(
	"n",
	"<localleader>cs",
	r_only(function()
		slime_send_line(("str(%s, max.level = 1)"):format(cword()))
	end),
	vim.tbl_extend("force", mapopts, { desc = "R chunk: str(<cword>) shallow" })
)

vim.keymap.set(
	"n",
	"<localleader>ca",
	r_only(function()
		slime_send_line(("args(%s)"):format(cword()))
	end),
	vim.tbl_extend("force", mapopts, { desc = "R chunk: args(<cword>)" })
)

vim.keymap.set(
	"n",
	"<localleader>cm",
	r_only(function()
		local w = cword()
		slime_send_line(("methods(class = class(%s)[1])"):format(w))
	end),
	vim.tbl_extend("force", mapopts, { desc = "R chunk: methods(class(<cword>)[1])" })
)

vim.keymap.set(
	"n",
	"<localleader>cS",
	r_only(function()
		local w = cword()
		slime_send_line(("if (isS4(%s)) slotNames(%s) else 'not S4'"):format(w, w))
	end),
	vim.tbl_extend("force", mapopts, { desc = "R chunk: slotNames(<cword>) if S4" })
)

---------------------------------------------------------------------
-- NEW (optional): better cmp behavior in Quarto while in R chunks
-- We apply a buffer-local source tweak, but only when cursor is in an R chunk.
-- This avoids making Quarto completion too noisy for prose / other languages.
---------------------------------------------------------------------
do
	local ok, cmp = pcall(require, "cmp")
	if ok then
		local aug = vim.api.nvim_create_augroup("QuartoCmpRChunk", { clear = true })

		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
			group = aug,
			buffer = 0,
			callback = function()
				if in_r_chunk() then
					cmp.setup.buffer({
						sources = cmp.config.sources({
							{ name = "nvim_lsp" },
							{ name = "luasnip" },
							{ name = "buffer", keyword_length = 2 },
							{ name = "path" },
							{ name = "spell" },
						}),
					})
				else
					-- Revert to a less noisy default for prose/other chunks.
					cmp.setup.buffer({
						sources = cmp.config.sources({
							{ name = "nvim_lsp" },
							{ name = "luasnip" },
							{ name = "buffer", keyword_length = 5 }, -- your global default
							{ name = "path" },
							{ name = "spell" },
						}),
					})
				end
			end,
		})
	end
end
