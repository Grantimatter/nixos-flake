{ pkgs, ... }:
{
  home = {
    username = "grant";
    stateVersion = "23.11";
    homeDirectory = "/home/grant";
  };

  programs.git = {
    enable = true;
    userName = "Grant Wiswell";
    userEmail = "wiswellgrant@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.zsh = {
    enable = true;
  };
}
