{ pkgs, config, inputs, ... }:
{
  imports = [ inputs.eden.homeModules.default ];
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

  programs.nnn.enable = true;
  programs.eden.enable = true;

  # xdg.mime.defaultApplications = {
  #   "text/html" = "zen.desktop";
  # };

  # users."grant".xdg.mimeApps = {
  #   enable = true;
  # };

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # Web Browser
      "text/html" = ["zen-twilight.desktop"];
      "application/pdf" = ["zen-twilight.desktop"];
      "application/x-extension-htm" = ["zen-twilight.desktop"];
      "application/x-extension-html"= ["zen-twilight.desktop"]; 
      "application/x-extension-shtml"= ["zen-twilight.desktop"]; 
      "application/x-extension-xht"= ["zen-twilight.desktop"]; 
      "application/x-extension-xhtml"= ["zen-twilight.desktop"]; 
      "application/xhtml+xml"= ["zen-twilight.desktop"]; 
    };
  };
}
