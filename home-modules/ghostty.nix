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
    };
  };
}
