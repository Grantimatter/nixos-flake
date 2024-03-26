{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) optionals attrValues;
in
{
  home.packages = attrValues
  {
    inherit (pkgs)
    cargo
    rustc

    git
    gh
    lazygit
    cloudflared

    ffmpeg
    wget
    zip
    unzip

    erdtree
    bottom
    eza
    bat

    jq
    glow
    ;
  };

  programs = {
    starship = {
      enable = true;
      enableZshIntegration = true;
    };

  git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      merge.conflictStyle = "diff3";
    };
  };

  ssh.enable = true;

  direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  };
}
