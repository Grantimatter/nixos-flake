{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      # shell-integration = "fish";
      font-family = "FiraCode Nerd Font Mono";
      keybind = [
        "ctrl+shift+o=unbind"
        "ctrl+shift+e=unbind"
        "ctrl+shift+i=unbind"
        "ctrl+shift+n=unbind"
        "ctrl+shift+w=unbind"
        "ctrl+shift+t=unbind"
        "ctrl+alt+left=unbind"
        "ctrl+alt+right=unbind"
        "ctrl+alt+up=unbind"
        "ctrl+alt+down=unbind"
        "ctrl+tab=unbind"
        "ctrl+shift+tab=unbind"
        "alt+left=unbind"
        "alt+right=unbind"
      ];
    };
  };
}
