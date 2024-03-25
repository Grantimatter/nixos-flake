{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) optionals attrValues;
  inherit (config.home) homeDirectory;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      set relativenumber
    '';
  };
}
