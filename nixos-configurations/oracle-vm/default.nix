{ config, inputs, lib, modulesPath, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  networking = {
    hostName = "oracle-vm";
    networkmanager.enable = true;
  };

  nix = {
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
