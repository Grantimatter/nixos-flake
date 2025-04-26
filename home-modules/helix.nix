{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) optionals attrValues;
  inherit (config.home) homeDirectory;
in
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
     theme = "catppuccin_mocha"; 
      editor = {
        line-number = "relative";
        scrolloff = 15;

        lsp.display-messages = true;
        completion-timeout = 100;
        completion-trigger-len = 1;

        color-modes = true;
        popup-border = "all";
        clipboard-provider = "clipse";
        indent-guides.render = true;
        indent-guides.skip-levels = 2;
      };
    };
  };

  home = {
    packages = (attrValues) {
      inherit (pkgs)
        # LSPs
        nil
        # rust-analyzer
        marksman
        lua-language-server
        typescript-language-server
        vscode-langservers-extracted
        zls
        bash-language-server
        dockerfile-language-server-nodejs
        docker-compose-language-service
        gopls
        haskell-language-server
        jdt-language-server

        # Linters
        clippy
        shellcheck

        # Formatters
        nixpkgs-fmt
        ;
    };
  };
}
