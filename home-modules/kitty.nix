{ config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    themeFile = "Catppuccin-Mocha";
    keybindings = {
      # Move Focus
      "ctrl+up" = "neighboring_window up";
      "ctrl+down" = "neighboring_window down";
      "ctrl+left" = "neighboring_window left";
      "ctrl+right" = "neighboring_window right";
      # Swap Windows
      "ctrl+shift+up" = "move_window up";
      "ctrl+shift+down" = "move_window down";
      "ctrl+shift+left" = "move_window left";
      "ctrl+shift+right" = "move_window right";
      # Resize Window
      "shift+up" = "resize_window taller 4";
      "shift+down" = "resize_window shorter 4";
      "shift+left" = "resize_window narrower 4";
      "shift+right" = "resize_window wider 4";
      # Layout Actions
      "f7" = "layout_action rotate";
    };
    settings = {
      # tab_bar_edge = "top";
      # tab_bar_style = "powerline";
      # tab_powerline_style = "angled";
      # tab_bar_min_tabs = 1;
      # tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{index}:{title} {tab.active_wd}/{tab.active_exe}";
    };
  };
}
