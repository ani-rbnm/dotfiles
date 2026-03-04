vim.b.slime_cell_delimiter = "#\\s\\=%%"

vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true

local function slime_send_buffer()
	vim.cmd("normal! ggVG")
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>SlimeRegionSend", true, true, true), "n", false)
end

local function new_terminal(cmd)
	vim.cmd("silent !tmux splitw -h " .. cmd .. " &")
end

local function new_terminal_python()
	new_terminal("python")
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

local mapopts = { buffer = true, silent = true }

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

-- send current line
vim.keymap.set("n", "<localleader>pl", "<Plug>SlimeLineSend", {
	buffer = true,
	desc = "[p] send current [l]ine",
})

-- send selected region (visual mode)
vim.keymap.set("x", "<localleader>pr", "<Plug>SlimeRegionSend", {
	buffer = true,
	desc = "[p] send selected [r]egion",
})

-- send entire file
vim.keymap.set("n", "<localleader>pf", slime_send_buffer, {
	buffer = true,
	desc = "[p] send entire [f]ile",
})
