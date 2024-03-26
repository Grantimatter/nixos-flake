{ config, inputs, lib, modulesPath, pkgs, ... }:
{
  imports = [
    ./harware-configuration.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  networking = {
    hostName = "desktop-nix";
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

  environment.shell = lib.attrValues {
    inherit (pkgs)
      zsh
      ;
  };

  system.stateVersion = "23.11";
}
