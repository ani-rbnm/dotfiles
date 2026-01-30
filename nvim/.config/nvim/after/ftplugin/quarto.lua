-- ~/.config/nvim/after/ftplugin/quarto.lua
-- User overrides for Quarto buffers (runs after plugin/runtime ftplugins)

local quarto = require("quarto")
local runner = require("quarto.runner")

-- Helpful for vim-slime cell motions; plugin sets this too, harmless here.
vim.b.slime_cell_delimiter = "```"

-- Keep this initialized; slime override checks it
vim.b.quarto_is_python_chunk = vim.b.quarto_is_python_chunk or false

-- Insert chunk helpers (quarto-nvim doesn't expose these)
local function is_code_chunk()
	local current = require("otter.keeper").get_current_language_context()
	return current ~= nil
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

-- tmux helpers (unchanged)
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

	-- 1) Preferred: per-project venv (you said you'll always have this)
	local venv_ipy = cwd .. "/.venv/bin/ipython"
	if vim.fn.executable(venv_ipy) == 1 then
		new_terminal(venv_ipy .. " -i --no-confirm-exit")
		return
	end

	-- 2) Poetry-aware fallback: only if this looks like a Poetry project AND Poetry exists
	local has_pyproject = (vim.fn.filereadable(cwd .. "/pyproject.toml") == 1)
	if has_pyproject and (vim.fn.executable("poetry") == 1) then
		new_terminal("poetry run ipython -i --no-confirm-exit")
		return
	end

	-- 3) Last resort: whatever ipython is on PATH (pipx/system)
	if vim.fn.executable("ipython") == 1 then
		new_terminal("ipython -i --no-confirm-exit")
		return
	end

	vim.notify(
		"ipython not found. Expected .venv/bin/ipython. (Poetry fallback also unavailable.)",
		vim.log.levels.WARN
	)
end

-- Buffer-local maps so plugin updates won't stomp them
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
