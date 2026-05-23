{ pkgs, inputs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
  email = "grantwiswell@proton.me";
in
{
  home = {
    username = "grant";
    stateVersion = "23.11";
    homeDirectory = "/home/grant";
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "Grant Wiswell";
      user.email = email;
      init.defaultBranch = "main";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = "Grant Wiswell";
      user.email = email;
    };
  };

  programs.claude-code = {
    enable = true;
    package = pkgs-unstable.claude-code;
  };

  programs.opencode = {
    enable = true;
    package = pkgs-unstable.opencode;
  };

  home.packages = with (pkgs-unstable); [
    claude-monitor
    claude-code-acp
  ];

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
      "x-scheme-handler/chrome"=["zen-twilight.desktop"];
      "x-scheme-handler/discord"=["vesktop.desktop"];
      "x-scheme-handler/http"=["zen-twilight.desktop"];
      "x-scheme-handler/https"=["zen-twilight.desktop"];
      "inode/directory"=["com.system76.CosmicFiles.desktop"];
      "org/gtk/Settings/FileChooser"=["com.system76.CosmicFiles.desktop"];

      # Media
      "image/jpeg" = ["org.gnome.Loupe.desktop"];
      "image/png" = ["org.gnome.Loupe.desktop"];
    };
  };
}
