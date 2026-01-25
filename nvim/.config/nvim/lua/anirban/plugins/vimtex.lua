return {
	"lervag/vimtex",
	ft = { "tex", "plaintex" },
	init = function()
		-- PDF viewer
		vim.g.vimtex_view_method = "zathura"

		-- Use latexmk with SyncTeX
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_compiler_latexmk = {
			options = {
				"-pdf",
				"-interaction=nonstopmode",
				"-synctex=1",
			},
		}

		-- Keep VimTeX mappings (includes `tsd` for delimiter modifier toggle)
		vim.g.vimtex_mappings_enabled = 1

		-- If you use TexLab for completion/diagnostics, disable VimTeX completion
		vim.g.vimtex_complete_enabled = 0

		-- Make `tsd` toggle ONLY: (...) <-> \left( ... \right)
		vim.g.vimtex_delim_toggle_mod_list = {
			{ "\\left", "\\right" },
		}
	end,
}
