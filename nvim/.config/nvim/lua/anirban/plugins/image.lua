-- plugin used by molten nvim. Will be lazy loaded.
return {
	"3rd/image.nvim",
	event = "VeryLazy",
	opts = {
		backend = "kitty",
		kitty_method = "normal",
		integrations = {
			-- Notice these are the settings for markdown files
			markdown = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				-- markdown extensions (ie. quarto) can go here
				filetypes = { "markdown", "vimwiki" },
			},
			neorg = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "norg" },
			},
			-- html = {
			-- 	enabled = true,
			-- },
			-- css = {
			-- 	enabled = true,
			-- },
		},
		max_width = 100,
		max_height = 12,
		max_height_window_percentage = math.huge,
		max_width_window_percentage = math.huge,
		window_overlap_clear_enabled = true,
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		editor_only_render_when_focused = true, --TODO: Remove this later
		tmux_show_only_in_active_window = true,
		hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
	},
}
