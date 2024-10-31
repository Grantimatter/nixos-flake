{ config, inputs, lib, modulesPath, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../nvidia.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" "module_blacklist=amdgpu" ];
  hardware.nvidia.forceFullCompositionPipeline = true;
  #hardware.nvidia.powerManagement.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.xserver = {
    enable = true;
#    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    desktopManager.xterm.enable = false;
#    displayManager.lightdm.enable = true;
#    displayManager.defaultSession = "none+i3";
#    windowManager.i3.enable = true;
    excludePackages = [ pkgs.xterm ];
#    layout = "us";
  };

  networking = {
    hostName = "nixos-desktop";
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
      # Dev
      git
      helix

      # Gaming
      lutris
      atlauncher
      ;
  };

  programs = {
    steam.enable = true;
    java.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";


  system.stateVersion = "23.11";
}
