vim.b.slime_cell_delimiter = "```"
vim.treesitter.language.register("markdown", { "quarto", "rmd" })

local config = require("quarto.config").config
local quarto = require("quarto")

if config.lspFeatures.enabled then
	quarto.activate()
end
-- Filetype specific keymaps for quarto
vim.g["quarto_is_r_mode"] = nil
vim.g["reticulate_running"] = false

local is_code_chunk = function()
	local current, _ = require("otter.keeper").get_current_language_context()
	if current then
		return true
	else
		return false
	end
end

--- Insert code chunk of given language
--- Splits current chunk if already within a chunk
--- @param lang string
local insert_code_chunk = function(lang)
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

local insert_r_chunk = function()
	insert_code_chunk("r")
end

local insert_py_chunk = function()
	insert_code_chunk("python")
end

local insert_rust_chunk = function()
	insert_code_chunk("rust")
end

local function new_terminal(lang)
	-- vim.cmd("vsplit term://" .. lang)
	vim.cmd("silent !tmux splitw -h " .. lang .. " &")
	-- vim.fn.jobstart({ "tmux", "splitw -h " .. lang }, { detach = true })
end

local function new_terminal_python()
	new_terminal("python")
end

local function new_terminal_r()
	new_terminal("R --no-save")
end

local function new_terminal_ipython()
	-- new_terminal("ipython --no-confirm-exit")
	new_terminal("ipython -i --no-confirm-exit")
end

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
local function send_cell()
	if vim.b["quarto_is_r_mode"] == nil then
		vim.fn["slime#send_cell"]()
		return
	end
	if vim.b["quarto_is_r_mode"] == true then
		vim.g.slime_python_ipython = 0
		local is_python = require("otter.tools.functions").is_otter_language_context("python")
		if is_python and not vim.b["reticulate_running"] then
			vim.fn["slime#send"]("reticulate::repl_python()" .. "\r")
			vim.b["reticulate_running"] = true
		end
		if not is_python and vim.b["reticulate_running"] then
			vim.fn["slime#send"]("exit" .. "\r")
			vim.b["reticulate_running"] = false
		end
		vim.fn["slime#send_cell"]()
	end
end

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
local slime_send_region_cmd = ":<C-u>call slime#send_op(visualmode(), 1)<CR>"
slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)
local function send_region()
	-- if filetyps is not quarto, just send_region
	if vim.bo.filetype ~= "quarto" or vim.b["quarto_is_r_mode"] == nil then
		vim.cmd("normal" .. slime_send_region_cmd)
		return
	end
	if vim.b["quarto_is_r_mode"] == true then
		vim.g.slime_python_ipython = 0
		local is_python = require("otter.tools.functions").is_otter_language_context("python")
		if is_python and not vim.b["reticulate_running"] then
			vim.fn["slime#send"]("reticulate::repl_python()" .. "\r")
			vim.b["reticulate_running"] = true
		end
		if not is_python and vim.b["reticulate_running"] then
			vim.fn["slime#send"]("exit" .. "\r")
			vim.b["reticulate_running"] = false
		end
		vim.cmd("normal" .. slime_send_region_cmd)
	end
end

vim.keymap.set("n", "<localleader>qp", quarto.quartoPreview, { silent = true, desc = "quarto - preview" })
vim.keymap.set("n", "<localleader>ip", insert_py_chunk, { silent = true, desc = "quarto - insert python chunk" })
vim.keymap.set("n", "<localleader>ir", insert_r_chunk, { silent = true, desc = "quarto - insert r chunk" })
vim.keymap.set("n", "<localleader>iu", insert_rust_chunk, { silent = true, desc = "quarto - insert rust chunk" })

vim.keymap.set("n", "<localleader>ni", new_terminal_ipython, { silent = true, desc = "quarto - new IPython terminal" })
vim.keymap.set("n", "<localleader>np", new_terminal_python, { silent = true, desc = "quarto - new Python terminal" })
vim.keymap.set("n", "<localleader>nr", new_terminal_r, { silent = true, desc = "quarto - new R terminal" })

vim.keymap.set("n", "<localleader><cr>", send_cell, { silent = true, desc = "quarto - run cell" })
vim.keymap.set("x", "<localleader><cr>", send_region, { silent = true, desc = "quarto - run region" })
