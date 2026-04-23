{ pkgs, inputs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system; };
in
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    enableBashIntegration = true;
    enableNushellIntegration = true;
    # enableFishIntegration = true;
    silent = true;
  };

  home.packages = with pkgs; [
    # devenv
  ] ++ (with pkgs-unstable; [
    devenv
  ]);
}
