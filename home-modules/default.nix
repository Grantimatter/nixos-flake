{ ezModules, lib, pkgs, ... }:
{
  imports = lib.attrValues {
    inherit (ezModules)
      neovim
      shell-generic
      shell-utils
      zsh
    ;
  };

  home = {
    packages = [ pkgs.bitwarden-cli ];
  };

  nixpkgs.config = import ../nixpkgs-config.nix;
  programs.home-manager.enable = true;
}
