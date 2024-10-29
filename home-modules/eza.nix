{ config, pkgs, ...}:
{
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    icons = true;
    git = true;

    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };
}
