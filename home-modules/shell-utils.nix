{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) optionals attrValues;
in
{
  home.packages = attrValues
  {
    inherit (pkgs)
      # cargo
      # rustc
      python3

      git
      git-lfs
      git-filter-repo
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
      duf
    	# rustscan
      
      jq
    	# tailspin # Commented due to build error
    	jless
    	grex
      glow
      killall
      ;
  };

  services.tldr-update.enable = true;

  programs = {
    gitui.enable = true;
    git-cliff.enable = true;
    bun.enable = true;
    superfile = {
      enable = true;
      settings = {
        theme = "catppuccin";
      };
    };

    carapace = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
    
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    git = {
      enable = true;
      delta.enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        merge.conflictStyle = "diff3";
       };
     };

    lazydocker = {
      enable = true;
    };

    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    gh = {
      enable = true;
    };

    #zellij = {
    #  enable = true;
    #  enableZshIntegration = true;
    #  enableBashIntegration = true;
    #};

    #alacritty = {
    #  enable = true;
    #};

    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    skim = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    ssh.enable = true;
  };
}
