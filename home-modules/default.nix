{ inputs, ezModules, catppuccin, lib, pkgs, ... }:
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
      ;
  } ++ [ inputs.catppuccin.homeModules.catppuccin ];

  home = {
    packages = [
      pkgs.bitwarden-cli
      pkgs.calibre
      pkgs.obsidian
      pkgs.zettlr
    ];
  };

  catppuccin.enable = true;
  catppuccin.flavor = catppuccin.flavor;
  catppuccin.accent = catppuccin.accent;
  catppuccin.gtk.enable = true;
  catppuccin.atuin.enable = false;
  catppuccin.starship.enable = true;
  catppuccin.cursors.enable = true;

  nixpkgs.config = import ../nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ../nixpkgs-config.nix;
  programs.home-manager.enable = true;
}
