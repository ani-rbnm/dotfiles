# dotfiles

## Desktop Setup
0. Base directory: dotfiles/
1. Windows manager tweaks - Check the 1-4, 7 checkboxes
2. copy themes
    rsync -av ./themes/Orchis* ~/.themes/
    rsync -av ./themes/Orchis* /usr/share/themes/
3. copy icons
    rsync -av ./icons/ ~/.local/share/icons/
    rsync -av ./icons/ /usr/share/icons/
4. Copy fonts
    rsync -av ./fonts/   ~/.local/share/fonts/
5. Copy wallpapers
    rsync -av ./usr /
6. quit xfce panel and xfconfd
    xfce4-panel --quit && pkill xfconfd
7. backup existing xfce4 config
    mv ~/.config/xfce4  ~/.config/xfce4-default
8. copy xfce config files and other misc. files. This will copy .config, .asset, .genmon-plugin
    rsync -av ./HOME/ ~/
9. run migrate_to_xfconf.sh as genmon no longer uses rc files.
10. Start xfce panel again
    xfce4-panel &
11. modify lightdm settings
    rsync -av ./etc /
12. Change the home icon in "Whisker Menu"
13. Appearance - Apply "Orchis Dark Compact" theme, "Tela Dark" icons, "IBM Plex Sans Regular"/"Firacode Nerd Font Mono Retina" font
14. Window Manager - Title font -> IBM Plex Sans Bold
15. Alacrity config
    1. updated toml file
    2. font needs to be present in ~/.local/share/fonts. Using "FiraCode Nerd Font Mono'. Download if needed.
    3. Install powerlevel10k
        A. lean, unicode, 8 colors, 12 hr, 2 lines, dottedd, left, black, sparse, many icons, concise, no transient prompts,
            verbose, yes, yes. (to reconfigure: p10k configure
        B. git clone https://github.com/alacritty/alacritty-theme.git ~/.config/alacritty/themes
        C. paste coolnight.toml into ~/.config/alacritty/themes/themes/

## Setup grub to hide boot menu
1. /etc/default/grub
    GRUB_TIMEOUT=5
    GRUB_TIMEOUT_STYLE=hidden
2. update grub config
    grub-mkconfig -o /boot/grub/grub.cfg
