{
  inputs,
  modulesPath,
  pkgs,
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
    nixpkgs-master
    ;
  pkgs-stable = import nixpkgs-stable { inherit system; };
  pkgs-master = import nixpkgs-master {
    inherit system;
    config = import ../../nixpkgs-config.nix;
  };
  # duckstation-wayland = pkgs-master.duckstation.overrideAttrs (oldAttrs: {
  #   postInstall = (oldAttrs.postInstall or "") + ''
  #     wrapProgram $out/bin/duckstation-qt --set QT_QPA_PLATFORM wayland
  #   '';
  # });
in
{
  imports = [
    ./hardware-configuration.nix
    ../nvidia.nix
    ../nix-ld.nix
    inputs.musnix.nixosModules.musnix
    inputs.eden.nixosModules.default
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

  hardware.nvidia.forceFullCompositionPipeline = false;
  hardware.nvidia.open = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ vulkan-loader ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ vulkan-loader ];
  };

  hardware.sane = {
    enable = true;
    brscan5.enable = true;
  };

  hardware.i2c.enable = true;

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

  services.croc = {
    enable = true;
    openFirewall = true;
    pass = "/run/secrets/croc";
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

  networking = {
    hostName = "nixos-desktop";

    # Custom DNS - Disabled while using Pihole
    networkmanager.enable = true;
    networkmanager.dns = "none";
    useDHCP = false;
    dhcpcd.enable = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];

    firewall.enable = true;
    firewall.allowPing = true;
    firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
  };

  services.jellyfin = {
    enable = true;
  };
  services.sunshine = {
    enable = true;
    openFirewall = true;
    autoStart = true;
    capSysAdmin = true;
  };

  services.n8n = {
    enable = true;
    openFirewall = true;
  };

  services.deluge = {
    enable = true;
    web.enable = true;
  };

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
    desktopManager.xterm.enable = false;
    excludePackages = [ pkgs.xterm ];
  };

  services.pipewire = {
    extraConfig.pipewire = {
      "01-quantum" = {
        "context.properties" = {
          "default.clock.allowed-rates" = [
            44100
            48000
            88200
            96000
            192000
          ];
        };
      };
    };
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    
    settings.trusted-users = [
      "root"
    ];

    settings.trusted-substituters = ["https://eden-flake.cachix.org"];
    settings.trusted-public-keys = ["eden-flake.cachix.org-1:9orwA5vFfBgb67pnnpsxBqILQlb2UI2grWt4zHHAxs8="];

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

      # Downloads
      motrix
      unrar

      # nix
      cachix

      # Gaming
      lutris
      atlauncher
      dualsensectl
      umu-launcher
      heroic
      cabextract
      glxinfo
      steam-rom-manager

      # Emulation
      ryubing
      tkmm
      jdkWithFX
      xwayland-run

      mame-tools
      # duckstation-wayland
      # duckstation
      ares

      # Nvidia
      nvidia-vaapi-driver

      # Hyprland
      xdg-desktop-portal-hyprland
      tuigreet
      nautilus
      cosmic-files
      cosmic-ext-calculator
      cosmic-settings
      gnome-calculator
      kdePackages.dolphin
      # shadps4

      # Creation
      kdePackages.kdenlive
      ardour
      coppwr
      audacity
      guitarix
      yabridge
      yabridgectl
      reaper

      # VST3 plugin requirements
      wineWowPackages.yabridge
      mesa
      libGL

      # Desktop
      amberol
      termusic
      rofi
      brightnessctl
      ddcutil

      # Printers (yay)
      naps2

      # Automation
      n8n
    ])
    ++ (with pkgs-stable; [
      lmms
    ]);

  programs = {
    adb = {
      enable = true;
    };
    eden.enable = true;
    steam.enable = true;
    steam.extraCompatPackages = with pkgs; [
      proton-ge-bin
      gamemode
    ];
    steam.gamescopeSession.enable = true;
    steam.protontricks.enable = true;
    java.enable = true;
    partition-manager.enable = true;
    obs-studio.enable = true;
    obs-studio.enableVirtualCamera = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  system.stateVersion = "23.11";
}
