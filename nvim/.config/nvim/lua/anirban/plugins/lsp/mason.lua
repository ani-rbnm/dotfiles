return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"jay-babu/mason-nvim-dap.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		-- for installation management of mason formatters
		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			--list of servers for mason to install
			ensure_installed = {
				"ansiblels",
				"antlersls",
				"asm_lsp",
				"awk_ls",
				"azure_pipelines_ls",
				"bashls",
				"clangd",
				"clojure_lsp",
				"cmake",
				"cssls",
				"cucumber_language_server",
				"jinja_lsp",
				"dockerls",
				"emmet_ls",
				"gopls",
				"graphql",
				"html",
				"htmx",
				"jdtls",
				"julials",
				"lua_ls",
				"perlnavigator",
				"prismals",
				"puppet",
				"pyright",
				"r_language_server",
				"ruby_lsp",
				"rust_analyzer",
				"sqls",
				"svelte",
				"ts_ls",
				"tailwindcss",
				"ltex",
				"texlab",
			},
			automatic_installation = false,
		})
		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", --prettier formatter
				"stylua", -- lua formatter
				-- "isort", -- python formatter
				-- "black", -- python formatter
				"ruff",
				-- "pylint",
				"eslint_d",
				"clang-format",
				"crlfmt",
				"cpplint",
				"codelldb", -- for debugging
			},
		})
	end,
}
