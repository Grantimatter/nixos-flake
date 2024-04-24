{ config, lib, pkgs, ...}:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) optionals attrValues;
  inherit (config.home) homeDirectory;
in
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = 
      ''
      -- Pull in the wezterm API
      local wezterm = require 'wezterm'
  
      -- This will hold the configuration.
      local config = wezterm.config_builder()


      -- This is where you actually apply your config choices

      -- For example, changing the color scheme:

      config.color_scheme = 'catpuccin-mocha'

      -- and finally, return the configuration to wezterm

      return config
      '';
   };
}
