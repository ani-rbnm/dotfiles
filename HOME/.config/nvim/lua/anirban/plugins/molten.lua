-- plugin to display jupyter notebooks in terminal
return {
	"benlubas/molten-nvim",
	-- below shouldn't be necessary as image is expected to be loaded through its own file
	dependencies = {
		"3rd/image.nvim",
		"nvimtools/hydra.nvim", -- to use hydra to navigate cells
	},
	build = ":UpdateRemotePlugins",
	init = function()
		-- keeping output closed by default. <cmd>noautocmd MoltenEnterOutput<CR> has been mapped to key to open output again.
		vim.g.molten_auto_open_output = false
		-- image.vim rather than wezterm image renderer used
		vim.g.molten_image_provider = "image.nvim"
		-- setting wrapping. Test and set accordingly later.
		vim.g.molten_wrap_output = true
		-- Output as virtual text. Allows outputs to be shown, works with images as per documentation
		vim.g.molten_virt_text_output = true
		-- set output to be a line below the \'\'\' cell delimiter
		vim.g.moten_virt_lines_off_by_1 = true

		-- Enable below based on visual preference.
		vim.g.molten_output_win_max_height = 20
		vim.g.molten_use_border_highlights = true

		-- keymappings
		vim.keymap.set("n", "<leader>ji", "<cmd>MoltenInit<CR>", { silent = true, desc = "jupyter - init kernel" })
		vim.keymap.set(
			"n",
			"<leader>je",
			"<cmd>MoltenEvaluateOperator<CR>",
			{ silent = true, desc = "jupyter - evaluate operator" }
		)
		vim.keymap.set(
			"n",
			"<leader>jc",
			"<cmd>MoltenReevaluateCell<CR>",
			{ silent = true, desc = "jupyter - reevaluate cell" }
		)
		vim.keymap.set(
			"v",
			"<leader>jv",
			"<cmd><C-u>MoltenEvaluateVisual<CR>gv",
			{ silent = true, desc = "jupyter - evaluate visual" }
		)
		vim.keymap.set(
			"n",
			"<leader>js",
			"<cmd>noautocmd MoltenEnterOutput<CR>",
			{ silent = true, desc = "jupyter - show output" }
		)
		vim.keymap.set(
			"n",
			"<leader>jh",
			"<cmd>MoltenHideOutput<CR>",
			{ silent = true, desc = "jupyter - hide output" }
		)
		vim.keymap.set("n", "<leader>jd", "<cmd>MoltenDelete<CR>", { silent = true, desc = "jupyter - delete cell" })

		-- adding autocmd for jupyter notebook kernel config etc.
		-- automatically import output chunks from a jupyter notebook
		-- tries to find a kernel that matches the kernel in the jupyter notebook
		-- falls back to a kernel that matches the name of the active virtual prompt.
		-- This prompt is set by poetry and is located in pyvenv.cfg
		local imb = function(e) -- init molten buffer
			vim.schedule(function()
				local kernels = vim.fn.MoltenAvailableKernels()
				local try_kernel_name = function()
					local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
					return metadata.kernelspec.name
				end
				local ok, kernel_name = pcall(try_kernel_name)
				if not ok or not vim.tbl_contains(kernels, kernel_name) then
					kernel_name = nil
					local venv = os.getenv("VIRTUAL_ENV_PROMPT")
					if venv ~= nil then
						kernel_name = venv
					end
				end
				if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
					vim.cmd(("MoltenInit %s"):format(kernel_name))
				end
				vim.cmd("MoltenImportOutput")
			end)
		end

		-- autocmd group to group the below autocmd's together
		local nbgroup = vim.api.nvim_create_augroup("nbgroup", { clear = true })

		-- automatically import output chunks from a jupyter notebook
		vim.api.nvim_create_autocmd("BufAdd", {
			group = nbgroup,
			pattern = { "*.ipynb" },
			callback = imb,
		})

		-- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
		vim.api.nvim_create_autocmd("BufEnter", {
			group = nbgroup,
			pattern = { "*.ipynb" },
			callback = function(e)
				if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
					imb(e)
				end
			end,
		})
		-- exporting output chunks to jupyter notebook on write
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = nbgroup,
			pattern = { "*.ipynb" },
			callback = function()
				if require("molten.status").initialized() == "Molten" then
					vim.cmd("MoltenExportOutput!")
				end
			end,
		})

		-- adding image.lua contents here

		-- require("image").setup({
		-- 	backend = "kitty",
		-- 	kitty_method = "normal",
		-- 	integrations = {
		-- 		markdown = {
		-- 			enabled = true,
		-- 			clear_in_insert_mode = false,
		-- 			download_remote_images = true,
		-- 			only_render_image_at_cursor = false,
		-- 			filetypes = { "markdown", "vimwiki" },
		-- 		},
		-- 		neorg = {
		-- 			enabled = true,
		-- 			clear_in_insert_mode = false,
		-- 			download_remote_images = true,
		-- 			only_render_image_at_cursor = false,
		-- 			filetypes = { "norg" },
		-- 		},
		-- 	},
		-- 	max_width = 100,
		-- 	max_height = 12,
		-- 	max_height_window_percentage = math.huge,
		-- 	max_width_window_percentage = math.huge,
		-- 	window_overlap_clear_enabled = true,
		-- 	window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		-- })
	end,
}
