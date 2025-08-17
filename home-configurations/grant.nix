{ pkgs, config, ... }:
{
  home = {
    username = "grant";
    stateVersion = "23.11";
    homeDirectory = "/home/grant";
    sessionPath = [ "$HOME/.local/share/cargo/bin" ];
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Grant Wiswell";
    userEmail = "wiswellgrant@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.jujutsu = {
    enable = true;
  };

  home.packages = with pkgs; [
    lazyjj
  ];

  home.users.grant = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "zen.desktop";
        "x-scheme-handler/http" = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "x-scheme-handler/about" = "zen.desktop";
        "x-scheme-handler/unknown" = "zen.desktop";
      };
    };
  };
  
  programs.nnn.enable = true;
}
