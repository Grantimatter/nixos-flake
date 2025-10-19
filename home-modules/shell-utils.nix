{ pkgs, ... }:
{
  home.packages = with pkgs; [
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
      bat-extras.batman
    	fd
    	procs
    	sd
    	du-dust
      duf
      
    	jaq
    	tailspin # Commented due to build error
    	jless
    	grex
      glow
      killall
  ];

  services.tldr-update.enable = true;

  programs = {
    gitui.enable = true;
    git-cliff.enable = true;
    bun.enable = true;
    bat.enable = true;

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
      enableNushellIntegration = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    fzf = {
      enable = true;
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

    vivid = {
      enable = true;
      activeTheme = "catppuccin-mocha";
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
