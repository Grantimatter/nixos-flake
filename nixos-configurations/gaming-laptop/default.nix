{ config, inputs, lib, modulesPath, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../nvidia.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
  
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.systemd-boot.enable = true;
  boot.plymouth.enable = true;
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "nodev";
  # boot.loader.grub.useOSProber = true;

  programs.steam.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.tailscale.enable = true;
  services.xserver = {
    enable = true;
    # displayManager.gdm.enable = true;
    desktopManager.xterm.enable = false;
#    displayManager.lightdm.enable = true;
#    displayManager.defaultSession = "none+i3";
#    windowManager.i3.enable = true;

    excludePackages = [ pkgs.xterm ];
    xkb.layout = "us";
    xkb.variant = "";
  };

  services.desktopManager = {
    gnome.enable = true;
    cosmic.enable = true;
  };

  networking = {
    hostName = "gaming-laptop";
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

  users.users.chloe = {
    isNormalUser = true;
    home = "/home/chloe";
    description = "Chloe Wiswell";
  };

  hardware.nvidia = {
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      sync.enable = true;
      open = true;
    };
  };

  environment.systemPackages = lib.attrValues {
    inherit (pkgs)
      git
      moonlight-qt
      firefox
      wezterm
      #wowup-cf
      r2modman
      deluge
      ;
  };

  system.stateVersion = "23.11";
}
