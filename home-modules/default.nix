{ ezModules, lib, pkgs, inputs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system; config.allowUnfree = true; };
in
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
      rio
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
      pkgs.zettlr
      pkgs-unstable.zed-editor
    ];
  };


  nixpkgs.config = import ../nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ../nixpkgs-config.nix;
  programs.home-manager.enable = true;
}
