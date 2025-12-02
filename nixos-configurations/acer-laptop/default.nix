{ config, inputs, lib, modulesPath, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../nvidia.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.plymouth.enable = true;

  programs.steam.enable = true;


  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic = {
    enable = true;
  };

  services.tailscale.enable = true;
  services.xserver = {
    enable = true;

    excludePackages = [ pkgs.xterm ];
    xkb.layout = "us";
    xkb.variant = "";
  };

  networking = {
    hostName = "acer-laptop";
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

#  hardware.nvidia.dynamicBoost.enable = true;

  hardware.nvidia = {
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      sync.enable = true;
    };
    open = false;
  };

  environment.systemPackages = lib.attrValues {
    inherit (pkgs)
      git
      neovim
      moonlight-qt
            ;
#     inherit (pkgs.gnomeExtensions)
#       hide-top-bar
#       pixel-saver
#       blur-my-shell
#       ;
  };

  system.stateVersion = "23.11";
}
