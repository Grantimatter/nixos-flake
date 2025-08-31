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
      ghostty
      zsh
      fish
      kitty
      xdg
      linux
      eww
      hyprland
      themes
      zen-browser
      direnv
      zellij
      ;
  };

  home = {
    packages = [
      pkgs.bitwarden-cli
      pkgs.calibre
      pkgs.zettlr
    ];
  };


  nixpkgs.config = import ../nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ../nixpkgs-config.nix;
  programs.home-manager.enable = true;
}
