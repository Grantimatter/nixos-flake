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
    dust
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
    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    bat.enable = true;

    broot = {
      enable = true;
      enableNushellIntegration = true;
    };

    bun.enable = true;

    carapace = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    fzf = {
      enable = true;
    };

    git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        merge.conflictStyle = "diff3";
      };
    };

    delta.enable = true;
    delta.enableGitIntegration = true;

    git-cliff.enable = true;

    gh = {
      enable = true;
    };

    lazydocker.enable = true;

    skim = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    vivid = {
      enable = true;
      activeTheme = "catppuccin-mocha";
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
