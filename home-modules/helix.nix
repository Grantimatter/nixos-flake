{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) optionals attrValues;
  inherit (config.home) homeDirectory;
in
{
  programs.helix = {
    enable = true;
    settings = {
     theme = "catppuccin_mocha"; 
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
      };
    };
    
  };

  home = {
    packages = (attrValues) {
      inherit (pkgs)
        # LSPs
        nil
        rust-analyzer
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
        rustfmt
        nixpkgs-fmt
        ;
    };
  };
}
