-- vim.cmd("let g:netrw_liststyle = 3")
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.g.netrw_liststyle = 3
-- This file will collate all global vars, other than those for which it makes sense to keep with other related items such as mapleader in keymaps.lua. This is however an exception
--
-- python path for molten plugin to run jupyter notebooks
-- vim.g.python3_host_prog = vim.fn.expand("$HOME") .. "/WorkArea/PythonProjects/MoltenPluginProject/.venv/bin/python"

-- prerequisite for image.nvim. needed to first install luarocks and then run the following
-- luarocks --local --lua-version=5.1 install magick
-- Example for configuring Neovim to load user-installed installed Lua rocks:
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"

local opt = vim.opt

opt.number = true
opt.relativenumber = true

-- Window split options
opt.splitbelow = true
opt.splitright = true

-- Used to suppress error message when updated in arglist is switch. Useful for 'argdo' command
opt.hidden = true
-- unnamed register synced with system clipboard register i.e '"+'
opt.clipboard:append("unnamedplus")

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Default indentation and replacement of tab with equivalent spaces(expandtab)
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.wrap = false

-- Search settings
opt.ignorecase = true -- ignore case while searching
opt.smartcase = true -- case-sensitive search if text includes mixed case

opt.cursorline = true -- highlight cursor line
opt.scrolloff = 999 -- keeps the cursor locked at the center of the screen

-- Turning spell on
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "gitcommit", "text" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_gb"
	end,
})

opt.statusline:append("%{&paste?'[PASTE]':''}")
