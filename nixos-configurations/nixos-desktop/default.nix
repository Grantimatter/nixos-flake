{
  config,
  inputs,
  modulesPath,
  pkgs,
  ...
}:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  disabledModules = [ "services/misc/n8n.nix" ];
  imports = [
    ./hardware-configuration.nix
    ../../nixos-modules/monitoring.nix
    ../../nixos-modules/sops.nix
    ../../nixos-modules/local-ai.nix
    ../../nixos-modules/honcho.nix
    ../nvidia.nix
    ../nix-ld.nix
    inputs.musnix.nixosModules.musnix
    inputs.hermes-agent.nixosModules.default
    inputs.eden.nixosModules.default
    (inputs.nixpkgs-unstable + "/nixos/modules/services/misc/n8n.nix")
    # (inputs.nixpkgs-unstable + "/nixos/pkgs/by-name/n8/n8n/package.nix")
    # <nixos-unstable/nixos/modules/services/misc/n8n.nix>
    # "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/n8n.nix"
    # inputs.hytale-launcher.hytale-launcher
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  musnix.enable = true;

  monitoring = {
    enable = true;
    nvidiaGpu = true;
  };

  local-ai.enable = true;

  services.honcho = {
    enable = true;
    openrouterApiKeyFile = config.sops.secrets."openrouter-key".path;
  };

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import inputs.nixpkgs-unstable {
        config = config.nixpkgs.config;
      };
    };

    cudaCapabilities = [ "8.9" ];
    cudaEnableForwardCompat = false;
  };

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
      consoleMode = "auto";
      editor = false;
    };
    loader.timeout = 0;
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
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
      # Sunshine Virtual Display
      # "video=DP-2:1920x1080R@60D"
    ];
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
    # pass = "/run/secrets/croc";
  };

  services.hermes-agent = {
    enable = true;
    container.enable = true;
    container.hostUsers = [ "grant" ];
    addToSystemPackages = true;
    environmentFiles = [ config.sops.secrets."hermes-env".path ];
    extraDependencyGroups = [ "honcho" ];
    settings.memory.provider = "honcho";
  };

  system.activationScripts."hermes-honcho-config" = {
    deps = [ "users" "hermes-agent-setup" ];
    text = ''
      install -o hermes -g hermes -m 0640 ${pkgs.writeText "hermes-honcho.json" ''
        {
          "baseUrl": "http://localhost:8000",
          "hosts": {
            "hermes": {
              "enabled": true,
              "aiPeer": "hermes",
              "workspace": "hermes",
              "recallMode": "hybrid",
              "sessionStrategy": "per-directory"
            }
          }
        }
      ''} /var/lib/hermes/.hermes/honcho.json
    '';
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };


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
    # networkmanager.enable = true;
    # networkmanager.dns = "none";
    # networkmanager.insertNameservers = [ "127.0.0.1" ];
    # useDHCP = false;
    # dhcpcd.enable = false;
    # nameservers = [
    #   "1.1.1.1"
    #   "1.0.0.1"
    #   "8.8.8.8"
    #   "8.8.4.4"
    # ];

    firewall.enable = true;
    firewall.allowPing = true;
    firewall.extraCommands = "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";
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
    configPackages = [
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-loopback.conf" ''
        context.modules = [
          { name = libpipewire-module-loopback
            args = {
              node.description = "Hisense 5.1 Suround"
              capture.props = {
                node.target = "alsa_output.pci-0000_01_00.1.hdmi-surround"
                node.passive = true
              }
              playback.props = {
                
              }
            }
          }
        ]
      '')
    ];
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-alsa-surround.lua" ''
        alsa_montor.rules {
          {
            matches = {{{ "node.name", "matches", "alsa_output.pci-0000_01_00.1.hdmi-surround"' }}};
            apply_properties = {
              ["audio.format"] = "dtshd-iec61937",
              ["audio.channels"] = 6,
              ["audio.position"] = "FL,FR,RL,RR,FC,LFE",
            },
          },
        }
      '')
    ];
    wireplumber.extraConfig = {
      "hdmi-surround" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "node.name" = "alsa_output.pci-0000_01_00.1.hdmi-surround";
              }
            ];
            actions = {
              update-props = {
                # "audio.channels" = "6";
                # "audio.position" = "FL,FR,RL,RR,FC,LFE";
              };
            };
          }
        ];
      };
    };
    # extraConfig.pipewire-pulse."99-dts.conf" = {
    #   pulse.rules = [
    #     {
    #       matches = [ { pulse.access = * } ]
    #     }
    #   ];
    # };
    # extraConfig.pipewire-pulse."99-ac3-passthrough" = {
    #   "pulse.rules" = [
    #     {
    #       matches = [ { "pulse.access"  = "*"; } ];
    #       actions = {
    #         "update-props" = {
    #           "pulse.formats" = "ac3-iec61937, eac-iec61937, pcm";
    #         };
    #       };
    #     }
    #   ];
    # };
    extraConfig.pipewire = {
      # "99-spdif-surround" = {
      #   "context.modules" = [
      #     {
      #       name = "libpipewire-module-filter-chain";
      #       args = {
      #         "node.description" = "Surround Sound AC3 Encoder";
      #         "node.name" = "Surround Sound AC3 Encoder";
      #         "filter.graph" = {
      #           nodes = [
      #             {
      #               type = "builtin";
      #               name = "mixer";
      #               label = "mixer";
      #             }
      #           ];
      #         };
      #       };
      #     }
      #   ];
      # };
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

    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixos-cuda.cachix.org-1:eDflBMRbSZdJOaZ1Op4yBtMBbPU6FObEMK0VCMzrOAQ="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  environment.systemPackages = (
    with pkgs;
    [
      sops
      age

      # Dev
      git
      godot
      helix
      adbtuifm
      qemu
      # jetbrains.rider
      ghidra

      # Downloads
      motrix
      unrar
      gparted

      # nix
      cachix

      # Gaming
      lutris
      atlauncher
      dualsensectl
      umu-launcher
      heroic
      cabextract
      mesa-demos
      steam-rom-manager
      # retroarch-full
      inputs.hytale-launcher.packages.x86_64-linux.hytale-launcher

      # Emulation
      ryubing
      tkmm
      # jdkWithFX
      xwayland-run

      mame-tools
      # duckstation-wayland
      # duckstation
      ares

      # Nvidia
      nvidia-vaapi-driver

      vulkan-tools

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
      zrythm

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
      affine
      signal-desktop

      # Printers (yay)
      naps2

      # Automation
      # n8n
      balena-cli

    ]
    ++ (
      with pkgs-unstable;
      [
        # AI
        nvtopPackages.nvidia  # GPU monitoring (nvidia + other vendors)
      ]
    )
  );

  programs = {
    adb = {
      enable = true;
    };
    eden.enable = true;
    eden.enableCache = true;
    steam.enable = true;
    steam.extraCompatPackages = with pkgs; [
      proton-ge-bin
      gamemode
    ];
    steam.gamescopeSession.enable = true;
    steam.protontricks.enable = true;
    java.enable = true;
    java.package = pkgs.jdk25_headless;
    partition-manager.enable = true;
    obs-studio.enable = true;
    obs-studio.enableVirtualCamera = true;
  };

  environment.variables = {
    # Point CUDA at the driver OpenGL libs NixOS provides
    CUDA_MODULE_LOADING     = "LAZY";
    # Uncomment to restrict to GPU 0 if you have multiple
    # CUDA_VISIBLE_DEVICES = "0";
    # Faster MTP: CUDA graph optimisation
    GGML_CUDA_GRAPH_OPT     = "1";

    NIXOS_OZONE_WL = "1";
  };

  system.stateVersion = "23.11";
}
