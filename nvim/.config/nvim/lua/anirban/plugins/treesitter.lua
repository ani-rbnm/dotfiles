return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
		},
	},
	config = function()
		local treesitter = require("nvim-treesitter")

		treesitter.install({
			"awk",
			"bash",
			"bibtex",
			"c",
			"clojure",
			"cmake",
			"cpp",
			"css",
			"csv",
			"cuda",
			"dockerfile",
			"gitignore",
			"go",
			"goctl",
			"gpg",
			"graphql",
			"html",
			"java",
			"javascript",
			"json",
			"latex",
			"llvm",
			"lua",
			"luadoc",
			"make",
			"markdown",
			"markdown_inline",
			"nginx",
			"perl",
			"php",
			"phpdoc",
			"printf",
			"prisma",
			"puppet",
			"python",
			"query",
			"r",
			"rust",
			"ruby",
			"scss",
			"sparql",
			"soql",
			"sql",
			"ssh_config",
			"svelte",
			"terraform",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"xml",
			"yaml",
		})

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)

				-- Tree-sitter indentation for all filetypes where a parser exists.
				pcall(function()
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end)
			end,
		})

		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
				selection_modes = {
					["parameter.outer"] = "v",
					["function.outer"] = "v",
					["class.outer"] = "<c-v>",
				},
				include_surrounding_whitespace = true,
			},
		})
		vim.keymap.set({ "x", "o" }, "af", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
		end, { desc = "Select outer function" })

		vim.keymap.set({ "x", "o" }, "if", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
		end, { desc = "Select inner function" })

		vim.keymap.set({ "x", "o" }, "ac", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
		end, { desc = "Select outer class" })

		vim.keymap.set({ "x", "o" }, "ic", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
		end, { desc = "Select inner class" })
	end,
}
