{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      shell-integration = "fish";
      font-family = "FiraCode Nerd Font Mono";
      keybind = [
        "alt+ctrl+u=resize_split:down,40"
        "alt+ctrl+y=resize_split:up,40"
        "alt+ctrl+l=resize_split:left,40"
        "alt+ctrl+apostrophe=resize_split:right,40"
      ];
    };
  };
}
