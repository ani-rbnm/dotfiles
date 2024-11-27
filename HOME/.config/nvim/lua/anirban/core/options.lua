vim.cmd("let g:netrw_liststyle = 3")

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

-- Autocommand group for project type specific indentation
vim.api.nvim_create_augroup("indent_settings", { clear = true })
-- Python indentation autocommand
-- TODO: Can this be managed better with a plugin? Investigate.
vim.api.nvim_create_autocmd("FileType", {
	desc = "Format python files",
	pattern = "python",
	group = "indent_settings",
	callback = function(opts)
		vim.bo[opts.buf].tabstop = 4
		vim.bo[opts.buf].softtabstop = 4
		vim.bo[opts.buf].shiftwidth = 4
	end,
})