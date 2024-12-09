-- quatro-nvim brings functionality of the quarto software to neovim.
return {
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			"jmbuhr/otter.nvim",
			"hrsh7th/nvim-cmp",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		-- ft = { "quarto", "markdown" },
		ft = { "quarto" },
		dev = false,
		-- opts = {},
		config = function()
			local quarto = require("quarto")

			quarto.setup({
				lspFeatures = {
					-- all languages to be supported by the jupyter notebook
					enabled = true,
					languages = { "r", "python", "rust" },
					chunks = "all",
					diagnostics = {
						enabled = true,
						triggers = { "BufWrite" },
					},
					completion = {
						enabled = true,
					},
				},
				-- 		-- keymap = {
				-- 		-- 	-- hover = "H",
				-- 		-- 	-- definition = "gd",
				-- 		-- 	-- rename = "<leader>rn",
				-- 		-- 	-- references = "gr",
				-- 		-- 	format = "<leader>gf",
				-- 		-- },
				-- 		-- codeRunner = {
				-- 		-- 	enabled = true,
				-- 		-- 	default_method = "molten",
				-- 		-- },
			})
			-- 	-- quarto runner keymaps
			-- 	-- local runner = require("quarto.runner")
			-- 	-- vim.keymap.set("n", "<leader>cc", runner.run_cell, { silent = true, desc = "jupyter - run current cell" })
			-- 	-- vim.keymap.set(
			-- 	-- 	"n",
			-- 	-- 	"<leader>cu",
			-- 	-- 	runner.run_above,
			-- 	-- 	{ silent = true, desc = "jupyter - run current cell and above" }
			-- 	-- )
			-- 	-- vim.keymap.set("n", "<leader>cA", function()
			-- 	-- 	runner.run_all(true)
			-- 	-- end, { silent = true, desc = "jupyter - run all cells" })
			-- 	-- vim.keymap.set("n", "<leader>cl", runner.run_line, { silent = true, desc = "jupyter - run current line" })
			-- 	-- vim.keymap.set("n", "<leader>cv", runner.run_range, { silent = true, desc = "jupyter - run visual range" })
		end,
	},
	{ -- send code from python/r/qmd documets to a terminal or REPL
		-- like ipython, R, bash
		"jpalardy/vim-slime",
		dev = false,
		init = function()
			vim.b["quarto_is_python_chunk"] = false
			Quarto_is_in_python_chunk = function()
				require("otter.tools.functions").is_otter_language_context("python")
			end

			vim.cmd([[
      let g:slime_dispatch_ipython_pause = 100
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
      return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
      return [a:text, "\n"]
      else
      return [a:text]
      end
      end
      endfunction
      ]])

			-- Anirban
			-- vim.g.slime_target = "neovim"
			vim.g.slime_target = "tmux"
			-- Anirban - end
			vim.g.slime_no_mappings = true
			vim.g.slime_python_ipython = 1
		end,
		config = function()
			-- Anirban
			-- vim.g.slime_input_pid = false
			-- vim.g.slime_suggest_default = true
			-- vim.g.slime_menu_config = false
			-- vim.g.slime_neovim_ignore_unlisted = true
			vim.g.slime_default_config = { ["socket_name"] = "default", ["target_pane"] = "{last}" }
			-- Anirban ends

			local function mark_terminal()
				local job_id = vim.b.terminal_job_id
				vim.print("job_id: " .. job_id)
			end

			local function set_terminal()
				vim.fn.call("slime#config", {})
			end
			vim.keymap.set("n", "<leader>cm", mark_terminal, { desc = "[m]ark terminal" })
			vim.keymap.set("n", "<leader>cs", set_terminal, { desc = "[s]et terminal" })
		end,
	},
	-- paste an image to markdown from the clipboard with :PasteImg
	"ekickx/clipboard-image.nvim",
}
