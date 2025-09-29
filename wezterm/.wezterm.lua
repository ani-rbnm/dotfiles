-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Object to hold the config
local config = wezterm.config_builder()

config.font = wezterm.font("Firacode Nerd Font Mono")
config.font_size = 11

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

config.window_background_opacity = 0.9

-- enabling kitty graphics protocol for more efficient image rendition: https://github.com/wez/wezterm/issues/986
config.enable_kitty_graphics = true

return config
