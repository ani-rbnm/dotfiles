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
					chunks = "curly",
					languages = { "r", "python", "rust" },
					diagnostics = {
						enabled = true,
						triggers = { "BufWrite" },
					},
					completion = {
						enabled = true,
					},
				},
				codeRunner = {
					enabled = true,
					default_method = "slime",
				},
			})
		end,
	},
	{
		-- send code from python/r/qmd documents to a terminal or REPL
		"jpalardy/vim-slime",
		dev = false,

		-- Ensure slime is loaded when Quarto runner wants it
		ft = { "quarto", "rmd", "python", "r" },

		init = function()
			-- Called from Vimscript before escaping/sending
			-- Must WRITE to a buffer-local var because the vimscript checks b:quarto_is_python_chunk
			Quarto_is_in_python_chunk = function()
				vim.b.quarto_is_python_chunk = require("otter.tools.functions").is_otter_language_context("python")
			end

			vim.cmd([[
      let g:slime_dispatch_ipython_pause = 100

      function SlimeOverride_EscapeText_quarto(text)
        call v:lua.Quarto_is_in_python_chunk()

        " If sending multi-line text to ipython, use %cpaste unless we're in an R-mode workflow
        if exists('g:slime_python_ipython')
              \ && len(split(a:text,"\n")) > 1
              \ && get(b:, 'quarto_is_python_chunk', 0)
              \ && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
          return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
        else
          return [a:text]
        end
      endfunction
    ]])

			vim.g.slime_target = "tmux"
			vim.g.slime_no_mappings = true
			vim.g.slime_python_ipython = 1
		end,

		config = function()
			vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }

			local function mark_terminal()
				local job_id = vim.b.terminal_job_id
				vim.print("job_id: " .. tostring(job_id))
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
