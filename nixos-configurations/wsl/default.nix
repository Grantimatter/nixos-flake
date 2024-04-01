{ config, inputs, lib, modulesPath, pkgs, ... }:
let
  nixos-wsl = builtins.fetchGit { 
    url = "https://github.com/nix-community/NixOS-WSL";
    rev = "34eda458bd3f6bad856a99860184d775bc1dd588";
  };
in
with lib;
{
  imports = [
    "${nixos-wsl}/modules"
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  wsl = {
    enable = true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.tailscale.enable = true;

  networking = {
    networkmanager.enable = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    settings.trusted-users = [
      "root"
    ];

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  environment.systemPackages = lib.attrValues {
    inherit (pkgs)
    git
    neovim
    ;
  };

  system.stateVersion = "23.11";
}
