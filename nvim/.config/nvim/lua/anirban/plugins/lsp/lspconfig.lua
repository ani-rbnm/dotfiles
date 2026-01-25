return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		local util = require("lspconfig.util")

		-- import mason_lspconfig plugin
		local mason_lspconfig = require("mason-lspconfig")

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "<leader>mo", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		local lsp_flags = {
			allow_incremental_sync = true,
			debounce_text_changes = 150,
		}
		-- Change the Diagnostic symbols in the sign column (gutter)

		-- Changing to the new way in which diagnostics is displayed in nvim 0.11+

		-- local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		-- for type, icon in pairs(signs) do
		-- 	local hl = "DiagnosticSign" .. type
		-- 	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		-- end

		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
		})

		vim.lsp.config("graphql", {
			capabilities = capabilities,
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		})
		-- configure emmet language server

		vim.lsp.config("emmet_ls", {
			capabilities = capabilities,
			filetypes = {
				"html",
				"typescriptreact",
				"javascriptreact",
				"css",
				"sass",
				"scss",
				"less",
				"svelte",
			},
		})

		vim.lsp.config(
			-- configure lua server (with special settings)
			"lua_ls",
			{
				capabilities = capabilities,
				settings = {
					Lua = {
						-- make the language server recognize 'vim' global
						diagnostics = {
							globals = { "vim" },
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			}
		)

		vim.lsp.config("pyright", {
			name = "pyright",
			cmd = { "pyright-langserver", "--stdio" },
			filetypes = { "python" },
			capabilities = capabilities,
			flags = lsp_flags,
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "workspace",
					},
				},
			},
			root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
			-- root_dir = function(bufnr, on_dir)
			-- 	local fname = vim.api.nvim_buf_get_name(bufnr)
			-- 	local root = util.root_pattern(".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(
			-- 		fname
			-- 	) or util.path.dirname(fname)
			-- 	on_dir(root)
			-- end,
			single_file_support = true,
		})
		vim.lsp.enable("pyright")
		-- Enable Pyright for Python buffers (Neovim 0.11+)
		-- vim.api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufNewFile" }, {
		-- 	pattern = "python",
		-- 	callback = function(args)
		-- 		vim.lsp.enable("pyright", { bufnr = args.buf })
		-- 	end,
		-- })
		--
		-- lspconfig.pyright.setup({
		-- 	capabilities = capabilities,
		-- 	flags = lsp_flags,
		-- 	settings = {
		-- 		python = {
		-- 			analysis = {
		-- 				autoSearchPaths = true,
		-- 				useLibraryCodeForTypes = true,
		-- 				diagnosticMode = "workspace",
		-- 			},
		-- 		},
		-- 	},
		-- 	root_dir = function(fname)
		-- 		return util.root_pattern(".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(fname)
		-- 			or util.path.dirname(fname)
		-- 	end,
		-- })
		--

		vim.lsp.config("clangd", {
			cmd = {
				"clangd",
				"--query-driver=/usr/bin/clang++*,/usr/bin/g++*",
			},
		})

		-- mason bin config path
		local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
		-- setting texlab
		vim.lsp.config("texlab", {
			cmd = { mason_bin .. "/texlab" },
			filetypes = { "tex", "plaintex", "bib" },
			flags = { debounce_text_changes = 200 },
			settings = {
				texlab = {
					build = {
						executable = "latexmk",
						args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
						onSave = true,
					},
					-- Let VimTeX handle viewing/synctex; keep forwardSearch off here (simpler)
				},
			},
		})
		-- setting ltex

		-- lspconfig.ltex.setup({
		vim.lsp.config("ltex", {
			cmd = { mason_bin .. "/ltex-ls" },
			cmd_env = {
				-- Space-separated JVM flags:
				JAVA_TOOL_OPTIONS = table.concat({
					"--enable-native-access=ALL-UNNAMED",
					"-Djdk.xml.totalEntitySizeLimit=0", -- 0 = unlimited; or pick a big number e.g. 5000000
				}, " "),
			},
			filetypes = { "markdown", "text", "tex", "plaintex", "rst" },
			flags = { debounce_text_changes = 200 },
			settings = {
				ltex = {
					language = "en-GB", -- change to "en-US" if you prefer
					additionalRules = { enablePickyRules = true },
					dictionary = { ["en-GB"] = { "Neovim", "Lua", "LSP", "TypeScript" } },
					disabledRules = { ["en-GB"] = { "OXFORD_SPELLING" } },
				},
			},
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "tex", "plaintex", "bib" },
			callback = function(args)
				vim.lsp.enable("texlab", { bufnr = args.buf })
				vim.lsp.enable("ltex", { bufnr = args.buf })
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "markdown", "text", "rst" },
			callback = function(args)
				vim.lsp.enable("ltex", { bufnr = args.buf })
			end,
		})
		-- vim.lsp.config("clangd", {
		-- 	cmd = {
		-- 		"clangd",
		-- 		"--background-index", -- build + cache index
		-- 		"--header-insertion=iwyu", -- auto-add #include on accept
		-- 		"--all-scopes-completion",
		-- 		"--query-driver=/usr/bin/clang++*,/usr/bin/g++*", -- discover system headers
		-- 	},
		-- })
		-- vim.lsp.config("svelte", {
		-- 	capabilities = capabilities,
		-- 	on_attach = function(client, bufnr)
		-- 		vim.api.nvim_create_autocmd("BufWritePost", {
		-- 			pattern = { "*.js", "*.ts" },
		-- 			callback = function(ctx)
		-- 				-- Here use ctx.match instead of ctx.file
		-- 				client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
		-- 			end,
		-- 		})
		-- 	end,
		-- })
	end,
}
