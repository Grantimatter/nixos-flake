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
    userName = "Grant Wiswell";
    userEmail = "wiswellgrant@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.nnn.enable = true;
  # programs.obs-studio.enable = true;
}
