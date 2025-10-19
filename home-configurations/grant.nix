{ ... }:
let email = "grantwiswell@proton.me";
in
{
  home = {
    username = "grant";
    stateVersion = "23.11";
    homeDirectory = "/home/grant";
    # sessionPath = [ "$HOME/.local/share/cargo/bin" ];
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Grant Wiswell";
    userEmail = email;
    extraConfig = {
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
