{ ezModules, lib, ... }:
{
  imports = lib.attrValues {
    inherit (ezModules)
      neovim
      shell-generic
      zsh
    ;
  };

  nixpkgs.config = import ../nixpkgs-config.nix;
  programs.home-manager.enable = true;
}
