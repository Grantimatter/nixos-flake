{ config, inputs, lib, modulesPath, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatfrom = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  service.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  service.tailscale.enable = true;

  networking = {
    hostName = "wsl";
    networkmanager.enable = true;
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes"
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
  }

  system.stateVersion = "23.11";
}
