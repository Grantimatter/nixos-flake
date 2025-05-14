{ inputs, modulesPath, catppuccin, pkgs, ... }:
let
  systemPackages = with pkgs; [
      # Hyprland
      hyprpolkitagent
      hyprshot
      kitty
      egl-wayland
      hyprpaper
      hyprcursor
      hyprpicker
      eww
      kdePackages.xwaylandvideobridge

      # Theming
      kdePackages.qtstyleplugin-kvantum

      # Core
      bash
      zsh
      nnn
      coreutils
      usbutils
      home-manager
      tealdeer

      # Audio
      libbs2b
      lxqt.pavucontrol-qt
      libsForQt5.qt5ct
      libsForQt5.qtstyleplugin-kvantum
      qjackctl

      # Input
      evtest
      overskride

      kdePackages.polkit-kde-agent-1
      # wine64
      # wine-wayland
      # wine64Packages.wayland
    ];
in
{
  time.timeZone = "US/Central";
  i18n.defaultLocale = "en_US.UTF-8";
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings.features.cdi = true;
  virtualisation.docker.rootless.daemon.settings.featurse.cdi = true;
  console.keyMap = "us";
  systemd.services.upower.enable = true;
  systemd.enableEmergencyMode = false;
  services.pulseaudio.enable = false;
  services.pulseaudio.extraConfig = "load-module module-combine-sink";
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.catppuccin.nixosModules.catppuccin
    # inputs.rust-overlay.overlays.default
    #../overlays
  ];

  nixpkgs.config = import ../nixpkgs-config.nix;

  environment = {
    pathsToLink = [ "/share/zsh" ];
    systemPackages = systemPackages ++ [ inputs.zen-browser.packages.x86_64-linux.default ];
  };
  
  documentation = {
    enable = true;
    man.enable = true;
    dev.enable = true;
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";

    settings = {
      trusted-users = [ "@wheel" ];
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    registry.nixpkgs.flake = inputs.nixpkgs;

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
  };

  catppuccin.enable = true;
  catppuccin.flavor = catppuccin.flavor;
  catppuccin.accent = catppuccin.accent;
  catppuccin.sddm.enable = false;
  catppuccin.fcitx5.enable = false;
  catppuccin.grub.enable = false;
  catppuccin.plymouth.enable = false;

  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.fira-code
    nerd-fonts.tinos
    fira-sans
  ];

  networking = {
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowPing = true;
    };
  };

  services.timesyncd = {
    enable = true;
    #servers = ["us.pool.ntp.org"];
  };

  users.defaultUserShell = pkgs.fish;

  users.users.grant = {
    isNormalUser = true;
    home = "/home/grant";
    description = "Grant";
    extraGroups = [ "wheel" "networkmanager" "docker" "jackaudio"];
    initialPassword = "password";
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFY4/o4gfaJwr/B0+aB51QwiOI4jGCYodnCWM7Pj8iYH grant wiswell@Grant-Desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMpXeGgPkUi9Vfb3LBinNk03/x07y4pYoHcRWcReZ4E grant@wsl"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDMez1O0MFXBZS1vQ6lYBb4SiGZwmlDwMzeJtdXIQLu grant@acer-laptop"
    ];
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;

    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      extraRules = [{
        groups = [ "wheel" ];
        commands = builtins.map
          (command: { inherit command; options = [ "NOPASSWD" ]; })
          [ "${pkgs.systemd}/bin/shutdown" "${pkgs.systemd}/bin/reboot" ];
      }];
    };
  };

  system = {
    stateVersion = "23.11";

    autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = [ "--update-input" "nixpkgs" "-L" ];
      dates = "02:00";
      randomizedDelaySec = "45min";
      allowReboot = true;
    };
  };

  services = {
    pipewire = {

      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    blueman.enable = true;
    thermald.enable = true;
    upower.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
    displayManager.sddm.enable = true;
    hypridle.enable = true;
    input-remapper = {
      enable = true;
      enableUdevRules = true;
    };
  };


  programs = {
    dconf.enable = true;
    zsh.enable = true;
    fish.enable = true;
    hyprland.enable = true;
    hyprland.withUWSM = true;
    gamemode.enable = true;
    gamemode.enableRenice = true;
    # gamescope.enable = true;
    # gamescope.capSysNice = true;
    # gamescope.args = [
    #   "--expose-wayland"
    #   # "--backend wayland"
    #   # "--hdr-enabled"
    #   # "--immediate-flips"
    #   "-W 3840"
    #   "-H 2160"
    #   "-w 3840"
    #   "-h 2160"
    #   # "-b"
    #   "-r 144"
    #   "-o 144"
    #   # "--adaptive-sync"
    # ];
    hyprlock.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
