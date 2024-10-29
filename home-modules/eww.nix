{ config, pkgs, ...}:
let
  inherit (config.xdg)
      configHome
    ;
in
{
  programs.eww = {
    enable = false;
    configDir = ./eww-config-dir;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
}
