return {
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"jay-babu/mason-null-ls.nvim", -- bridges Mason <-> none-ls sources
		},
		ft = { "markdown", "text", "tex", "plaintex", "rst" },
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = { "vale" },
				automatic_installation = true,
			})

			local null = require("null-ls")
			null.setup({
				sources = {
					-- Vale diagnostics only for prose filetypes
					null.builtins.diagnostics.vale.with({
						filetypes = { "markdown", "text", "tex", "plaintex", "rst" },
						--                                   -- You can pass extra_args if you keep a project/local .vale.ini
						--                                               -- extra_args = { "--minAlertLevel", "suggestion" },
					}),
				},
				diagnostics_format = "[#{c}] #{m}", -- e.g. [warning] Message
				update_in_insert = false,
			})

			vim.keymap.set("n", "<leader>vt", function()
				require("null-ls").toggle({})
				vim.notify("Toggled Vale (none-ls)")
			end, { desc = "Toggle Vale diagnostics" })
		end,
	},

	-- (Optional) Markdown / LaTeX niceties
	{ "plasticboy/vim-markdown", ft = { "markdown" } },
}
