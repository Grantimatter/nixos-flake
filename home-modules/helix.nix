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
}
