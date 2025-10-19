{ config, pkgs, ...}:
{
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    # enableNushellIntegration = true;
    icons = "auto";
    git = true;

    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };
}
