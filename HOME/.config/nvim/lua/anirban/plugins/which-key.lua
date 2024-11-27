-- plugin to help remember the keymaps
-- when part of a keymap is pressed, for eg. <leader>c, it will display all keymaps
-- starting with it on the screen
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	opts = {
		-- extra configs here
		-- or leave it empty for defaults
	},
}
