{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) optionals attrValues;
  inherit (config.home) homeDirectory;
in
{
  home = {
    packages = (attrValues) {
      inherit (pkgs)

        ripgrep
        ripgrep-all

        # LSPs
        # rust-analyzer
        nil

        # Linters
        clippy
        shellcheck

        # Formatters
        # rustfmt
        nixpkgs-fmt
        beautysh
        ;
    };
  };
}
