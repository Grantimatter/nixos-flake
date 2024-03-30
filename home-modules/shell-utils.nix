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
	fd
	procs
	sd
	du-dust

        jq
        glow
        ;
    };

  programs = {
    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      diff-so-fancy = {
        enable = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        merge.conflictStyle = "diff3";
	credential."https://github.com".helper = "!${
	  pkgs.gh
	}/bin/gh auth git-credential";
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
