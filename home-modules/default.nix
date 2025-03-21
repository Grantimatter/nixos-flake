{ ezModules, lib, pkgs, ... }:
{
  imports = lib.attrValues {
    inherit (ezModules)
      wezterm
      helix
      shell-generic
      shell-utils
      eza
      nushell
      zsh
      fish
      kitty
      xdg
      linux
      eww
      hyprland
      ;
  };

  home = {
    packages = [
      pkgs.bitwarden-cli
      pkgs.calibre
      pkgs.obsidian
    ];
  };

  nixpkgs.config = import ../nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ../nixpkgs-config.nix;
  programs.home-manager.enable = true;
}
