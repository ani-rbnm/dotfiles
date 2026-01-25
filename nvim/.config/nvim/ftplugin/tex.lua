-- Optional: key to open PDF via VimTeX
vim.keymap.set("n", "<localleader>v", "<cmd>VimtexView<cr>", { silent = true, desc = "VimTeX View" })

-- Optional: key for \left...\right toggle (instead of tsd)
vim.keymap.set(
	{ "n", "x" },
	"<localleader>d",
	"<Plug>(vimtex-delim-toggle-modifier)",
	{ silent = true, desc = "Toggle \\left/\\right" }
)
