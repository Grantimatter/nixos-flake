{ config, inputs, lib, modulesPath, pkgs, ... }:
let
   shadps4b = pkgs.shadps4.overrideAttrs (oa: {
        version = "0.6.0";
        
        src = pkgs.fetchFromGitHub {
          owner = "shadps4-emu";
          repo = "shadPS4";
          tag = "v.0.6.0";
          fetchSubmodules = true;
          hash = "sha256-uzbeWhokLGvCEk3COXaJJ6DHvlyDJxj9/qEu2HnuAtI=";
        };

        patches = [];
  });
in
{
  imports = [
    ./hardware-configuration.nix
    ../nvidia.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # shadps4 = pkgs.shadps4.overrideAttrs (finalAttrs: previousAttrs: {
  #   version = "0.6.0";
  #   src = fetchFromGitHub {
  #     owner = "shadps4-emu";
  #     repo = "shadPS4";
  #     tag = "v.0.6.0";
  #     fetchSubmodules = true;
  #     hash = "sha256-uzbeWhokLGvCEk3COXaJJ6DHvlyDJxj9/qEu2HnuAtI=";
  #   };
  # });

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" "module_blacklist=amdgpu" ];
  hardware.nvidia.forceFullCompositionPipeline = false;
  #hardware.nvidia.powerManagement.enable = true;

  fileSystems."/mnt/nvme0n1p2" = {
    device = "/dev/disk/by-uuid/3A828F16828ED633";
    fsType = "ntfs-3g";
    options = ["rw" "uid=1000" "x-gvfs-show"];
  };

  fileSystems."/mnt/sdb2" = {
    device = "/dev/disk/by-uuid/3E0C584A0C57FB7B";
    fsType = "ntfs";
    neededForBoot = false;
    options = ["rw" "uid=1000" "x-gvfs-show" "nofail"];
  };

  fileSystems."/mnt/NVMEG" = {
    device = "/dev/disk/by-uuid/70EC442EEC43ECC2";
    fsType = "ntfs";
    neededForBoot = false;
    options = ["rw" "uid=1000" "x-gvfs-show" "nofail"];
  };

  fileSystems."/mnt/Games" = {
    device = "/dev/disk/by-uuid/ee7603cd-7a67-4b24-a6c2-eecb0a92075c";
    neededForBoot = false;
    fsType = "ext4";
    options = [ "nofail" "rw" "x-gvfs-show" "x-initrd.mount" ];
    # options = ["rw" "uid=1000" "x-gvfs-show" "nofail"];
  };
  
  fileSystems."/mnt/sda2" = {
    device = "/dev/disk/by-uuid/C076DEC576DEBB7C";
    fsType = "ntfs";
    neededForBoot = false;
    options = ["rw" "uid=1000" "x-gvfs-show" "nofail"];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "public" = {
        "path" = "/mnt/Shares/Public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "username";
        "force group" = "groupname";
      };
      "private" = {
        "path" = "/mnt/Shares/Private";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "username";
        "force group" = "groupname";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';

  services.plex = {
    enable = true;
    openFirewall = true;
    # user = "grant";
  };
  services.jellyfin = {
    enable = true;
  };

  services.deluge.enable = true;
  services.greetd.enable = true;

  services.xserver = {
    enable = true;
    # displayManager.gdm.enable = true;
    # desktopManager.gnome.enable = true;
    desktopManager.xterm.enable = false;
    # displayManager.lightdm.enable = true;
    # displayManager.defaultSession = "none+i3";
    # windowManager.i3.enable = true;
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

  environment.systemPackages = with pkgs; [
      # Dev
      git
      helix
      
      # Gamedev
      godot_4      
      unityhub

      # Downloads
      motrix
      
      # Gaming
      lutris
      atlauncher

      # Nvidia
      nvidia-vaapi-driver

      # Hyprland
      xdg-desktop-portal-hyprland
      greetd.tuigreet
      # shadps4b
      shadps4b
    ];

  programs = {
    steam.enable = true;
    steam.protontricks.enable = true;
    java.enable = true;
    partition-manager.enable = true;
    obs-studio.enable = true;
    obs-studio.enableVirtualCamera = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";


  system.stateVersion = "23.11";
}
