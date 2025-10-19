{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    enableBashIntegration = true;
    enableNushellIntegration = true;
    # enableFishIntegration = true;
    silent = true;
  };

  home.packages = with pkgs; [
    devenv
  ];
}
