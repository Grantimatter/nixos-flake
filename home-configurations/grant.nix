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

  dconf = {
    enable = true;
    settings = {
      "org/gnome/interface".color-scheme = "prefer-dark";
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
	binding = "<Ctrl><Alt>t";
	command = "alacritty";
	name = "Alacritty Terminal";
      };
    };
  };

  programs.zsh = {
    enable = true;
  };
}
