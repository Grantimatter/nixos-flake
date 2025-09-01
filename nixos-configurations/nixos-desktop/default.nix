{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  pkgs-stable,
  fetchzip,
  buildDotnetModule,
  ...
}:
let
  jdkWithFX = pkgs.openjdk.override {
    enableJavaFX = true;
    openjfx_jdk = pkgs.openjfx.override { withWebKit = true; };
  };
  inherit (pkgs) system;
  inherit (inputs)
    nixpkgs-stable
    ;
  pkgs-stable = import nixpkgs-stable { inherit system; };
in
{
  imports = [
    ./hardware-configuration.nix
    ../nvidia.nix
    ../nix-ld.nix
    inputs.musnix.nixosModules.musnix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  musnix.enable = true;

  boot = {
    plymouth = {
      enable = true;
      theme = "lone";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [
            "lone"
          ];
        })
      ];
    };
    consoleLogLevel = 3;
    initrd.verbose = false;
    loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
      editor = false;
    };
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "module_blacklist=amdgpu"
      "nvidia_drm.fbdev=1"
      "nvidia_drm.modeset=1"
      "nvidia_modeset.hdmi_deepcolor=1"
      "hdmi_deepcolor=1"
      "nvidia-modeset.hdmi_deepcolor=1"
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    loader.timeout = 0;
    kernelModules = [
      "snd-seq"
      "snd-rawmidi"
    ];
  };
  # boot.extraModProbeConfig = ''
  # options nvidia_drm modeset=1
  # options nvidia_drm fbdev=1
  # '';

  hardware.nvidia.forceFullCompositionPipeline = false;

  hardware.graphics = {
    enable = true;
    # driSupport = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ vulkan-loader ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ vulkan-loader ];
  };

  hardware.sane = {
    enable = true;
    brscan5.enable = true;
  };

  hardware.i2c.enable = true;
  #hardware.nvidia.powerManagement.enable = true;

  fileSystems."/mnt/nvme0n1p2" = {
    device = "/dev/disk/by-uuid/3A828F16828ED633";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
      "x-gvfs-show"
    ];
  };

  fileSystems."/mnt/sdb2" = {
    device = "/dev/disk/by-uuid/3E0C584A0C57FB7B";
    fsType = "ntfs";
    neededForBoot = false;
    options = [
      "rw"
      "uid=1000"
      "x-gvfs-show"
      "nofail"
    ];
  };

  fileSystems."/mnt/NVMEG" = {
    device = "/dev/disk/by-uuid/70EC442EEC43ECC2";
    fsType = "ntfs";
    neededForBoot = false;
    options = [
      "rw"
      "uid=1000"
      "x-gvfs-show"
      "nofail"
    ];
  };

  fileSystems."/mnt/Games" = {
    device = "/dev/disk/by-uuid/ee7603cd-7a67-4b24-a6c2-eecb0a92075c";
    neededForBoot = false;
    fsType = "ext4";
    options = [
      "nofail"
      "rw"
      "x-gvfs-show"
      "x-initrd.mount"
    ];
    # options = ["rw" "uid=1000" "x-gvfs-show" "nofail"];
  };

  fileSystems."/mnt/sda2" = {
    device = "/dev/disk/by-uuid/C076DEC576DEBB7C";
    fsType = "ntfs";
    neededForBoot = false;
    options = [
      "rw"
      "uid=1000"
      "x-gvfs-show"
      "nofail"
    ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.onlyoffice.enable = true;

  services.printing = {
    enable = true;
    drivers = [
      pkgs.brlaser
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        security = "user";
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
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
  services.deluge.web.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet -r --remember-session --time --user-menu --theme border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red";
      };
    };
  };
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOuput = "tty";
    StandardError = "journal";

    TTYReset = true;
    TTYHangup = true;
    TTYVTDisallocate = true;
  };
  systemd.services.NetworkManager-wait-online.enable = false;

  services.xserver = {
    enable = true;
    # desktopManager.gnome.enable = true;
    # displayManager.gdm.enable = true;
    # displayManager.gdm.wayland = false;
    desktopManager.xterm.enable = false;
    excludePackages = [ pkgs.xterm ];
    #    layout = "us";
  };

  services.pipewire = {
    extraConfig.pipewire = {
      "01-quantum" = {
        "context.properties" = {
          "default.clock.rate" = 192000;
          "default.clock.allowed-rates" = [
            44100
            48000
            88200
            96000
            192000
          ];
          "default.clock.min-quantum" = 16;
          "default.clock.max-quantum" = 1024;
          "default.clock.quantum" = 64;
          "default.clock.quantum-floor" = 4;
          "default.clock.quantum-limit" = 8192;
        };
      };
    };
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

  environment.systemPackages =
    (with pkgs; [
      # Dev
      git
      helix
      adbtuifm
      qemu
      jetbrains.rider

      # Gamedev
      godot_4
      # unityhub

      # Unreal Engine
      p4
      p4d
      p4v

      # Downloads
      motrix
      unrar

      # Gaming
      lutris
      atlauncher
      dualsensectl
      umu-launcher
      heroic
      cabextract
      glxinfo

      ## Ryujinx
      # ryujinx-new
      ryubing
      tkmm
      jdkWithFX
      xwayland-run

      # Nvidia
      nvidia-vaapi-driver

      # Hyprland
      xdg-desktop-portal-hyprland
      tuigreet
      # shadps4b
      nautilus
      cosmic-files
      cosmic-ext-calculator
      cosmic-settings
      gnome-calculator
      kdePackages.dolphin
      shadps4

      # Creation
      kdePackages.kdenlive
      ardour
      coppwr
      audacity
      guitarix
      yabridge
      yabridgectl
      pianobooster

      # VST3 plugin requirements
      wineWowPackages.yabridge
      mesa
      libGL

      # Desktop
      amberol
      termusic
      rofi-wayland
      brightnessctl
      ddcutil
      librewolf-wayland

      # Printers (yay)
      naps2
    ])
    ++ (with pkgs-stable; [
      lmms
    ]);

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     ryubing = prev.ryubing.override {
  #       # extraPkgs = pkgs: with pkgs; [
  #       #   xorg.libX11.dev
  #       # ];
  #       pname = "lol";
  #     };
  #   })
  # ];

  programs = {
    adb = {
      enable = true;
    };
    steam.enable = true;
    steam.extraCompatPackages = with pkgs; [
      proton-ge-bin
      gamemode
    ];
    # steam.extraPackages = (pkgs: with pkgs; [
    #   gamemode
    # ]);
    steam.gamescopeSession.enable = true;
    steam.protontricks.enable = true;
    java.enable = true;
    partition-manager.enable = true;
    obs-studio.enable = true;
    obs-studio.enableVirtualCamera = true;
  };

  systemd.services.p4d-service = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    description = "P4 (Perforce Helix) Server";
    serviceConfig = {
      Type = "simple";
      # ExecStart = ''${pkgs.p4d}/bin/p4d -p 1666 -r /mnt/sdb2/Git/P4ROOT -xD LILAC20250610'';
      ExecStart = ''${pkgs.p4d}/bin/p4d -p 192.168.1.183:1666 -r /mnt/sdb2/Git/P4ROOT'';
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  system.stateVersion = "23.11";
}
