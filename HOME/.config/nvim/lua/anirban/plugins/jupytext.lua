-- Required to convert between .ipynb and .qmd.
-- This is part of the molten plugin setup to use jupyter notebooks in neovim
return {
	"GCBallesteros/jupytext.nvim",
	config = function()
		require("jupytext").setup({
			style = "markdown",
			output_extension = "md",
			force_ft = "markdown",
		})
	end,
	lazy = false, -- There was a comment that if lazy loaded, "inscrutable JSON" might be observed in certain cases. Being safe here.
}
