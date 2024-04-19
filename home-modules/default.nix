{ ezModules, lib, pkgs, ... }:
{
  imports = lib.attrValues {
    inherit (ezModules)
#      neovim
      nixvim
      helix
      shell-generic
      shell-utils
      zsh
      xdg
      linux
      ;
  };

  home = {
    packages = [ pkgs.bitwarden-cli ];
  };

  nixpkgs.config = import ../nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ../nixpkgs-config.nix;
  programs.home-manager.enable = true;
}
