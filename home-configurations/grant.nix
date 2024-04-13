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

  xsession = {
    enable = true;
    windowManager.i3 = rec {
      enable = true;
      config = {
	modifier = "Mod4";
      };
    };
  };

  programs.zsh = {
    enable = true;
  };

  programs.autorandr.enable = true;
  services.autorandr.enable = true;

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
  };
}
