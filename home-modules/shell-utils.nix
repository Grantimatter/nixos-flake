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
        lazygit
        cloudflared

        ffmpeg
        wget
        zip
        unzip

        erdtree
        bottom
        eza
	ripgrep
	ripgrep-all
        bat
	fd
	procs
	sd
	du-dust
	rustscan

        jq
	tailspin
	jless
	grex
        glow
	killall
        ;
    };

  programs = {
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      delta.enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        merge.conflictStyle = "diff3";
       };
     };

    gh = {
      enable = true;
    };

    zellij = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    alacritty = {
      enable = true;
    };

    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    skim = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    ssh.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
