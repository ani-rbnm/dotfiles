return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		-- import nvim-treesitter configs
		local treesitter = require("nvim-treesitter.configs")

		-- configure treesitter
		treesitter.setup({
			-- enable syntax highlighting
			highlight = { enable = true },
			-- enable indentation
			indent = { enable = true },
			-- enable autotagging ( works with nvim-ts-autotagging plugin)
			autotag = { enable = true },
			-- make sure below language parsers are installed
			ensure_installed = {
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
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			textobjects = {
				move = {
					enable = true,
					set_jumps = false,
					goto_next_start = {
						-- jupyter notebook specific motions
						-- put a file in the location ~/.config/nvim/after/queries/markdown/textobjects.scm with the followin
						-- before enabling below line:
						--;; extends
						-- (fenced_code_block (code_fence_content) @code_cell.inner) @code_cell.outer
						-- [[ ["]b"] = { query = "@code_cell.inner", desc = "next code block" }, ]]
						["]b"] = { query = "@block.inner", desc = "next code block" },
					},
					goto_previous_start = {
						-- jupyter notebook specific motions
						-- ["[b"] = { query = "@code_cell.inner", desc = "previous code block" },
						["[b"] = { query = "@block.inner", desc = "previous code block" },
					},
				},
				select = {
					enable = true,
					-- Automatically jump forward to textobj, similar to targets.vim
					lookahead = true,
					keymaps = {
						-- You can use the capture groups defined in textobjects.scm
						-- Anirban: We can find out more about below capture groups and its scheme file using :TSEditQuery command.
						-- Eg. :TSEditQuery textobjects
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						-- You can optionally set descriptions to the mappings (used in the desc parameter of
						-- nvim_buf_set_keymap) which plugins like which-key display
						["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
						-- You can also use captures from other query groups like `locals.scm`
						["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
						--Adding jupyter block specific motions
						["ib"] = { query = "@code_cell.inner", desc = "select inner part of jupyter notebook block" },
						["ab"] = { query = "@code_cell.outer", desc = "select outer part of jupyter notebook block" },
					},
					-- You can choose the select mode (default is charwise 'v'). Other possible ones 'V' (for linewise) and '<c-v>'(blockwise)
					-- mapping query_strings to modes.
					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "v", -- linewise
						["@class.outer"] = "<c-v>", -- blockwise
					},
					-- If you set this to `true` (default is `false`) then any textobject is
					-- extended to include preceding or succeeding whitespace. Succeeding
					-- whitespace has priority in order to act similarly to eg the built-in
					-- `ap`.
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * selection_mode: eg 'v'
					-- and should return true or false
					include_surrounding_whitespace = true,
				},
			},
		})
	end,
}
