-- mason-nvim-dap needs to be setup after mason but since this is lazy loaded
-- before opening a buffer, that requirement will be satisfied even though it is loaded
-- in this separate file.
return {
	"rcarriga/nvim-dap-ui",
	event = "VeryLazy",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
		--	{ "jay-babu/mason-nvim-dap.nvim", opts = { handlers = {} } },
		"jay-babu/mason-nvim-dap.nvim",
	},
	config = function()
		local dap = require("dap")
		require("mason-nvim-dap").setup({
			handlers = {},
		})
		local dapui = require("dapui")
		dapui.setup()
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.after.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- Debugger keymaps
		vim.keymap.set("n", "<leader>gb", "<cmd>DapToggleBreakpoint<CR>", { desc = "Add Breakpoint at line" })
		vim.keymap.set("n", "<leader>gr", "<cmd>DapContinue<CR>", { desc = "Start or continue the debugger" })
	end,
}
