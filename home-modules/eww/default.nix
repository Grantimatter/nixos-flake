{ ... }:
{
  programs.eww = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  xdg.configFile."eww".source = ./config;
  xdg.configFile."eww".recursive = true;
}
