{ inputs, modulesPath, pkgs, ... }:
let
  systemPackages = with pkgs; [
      # Hyprland
      hyprshot
      kitty
      egl-wayland
      hyprpaper
      hyprcursor
      eww
      kdePackages.xwaylandvideobridge

      # Theming
      catppuccin-cursors

      # Core
      bash
      zsh
      nnn
      coreutils
      usbutils
      home-manager

      # Audio
      libbs2b
      pavucontrol
      qjackctl

      kdePackages.polkit-kde-agent-1
      # wine64
      # wine-wayland
      wine64Packages.wayland
    ];

in
{
  time.timeZone = "US/Central";
  i18n.defaultLocale = "en_US.UTF-8";
  virtualisation.docker.enable = true;
  console.keyMap = "us";
  systemd.services.upower.enable = true;
  systemd.enableEmergencyMode = false;
  hardware.pulseaudio.enable = false;
  hardware.pulseaudio.extraConfig = "load-module module-combine-sink";
  hardware.bluetooth.enable = true;

  systemd = {
    user.services."polkit-agent" = {
      description = "polkit-kde-agent for Hyprland";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    #../overlays
  ];

  nixpkgs.config = import ../nixpkgs-config.nix;

  environment = {
    pathsToLink = [ "/share/zsh" ];
    systemPackages = systemPackages ++ [ inputs.zen-browser.packages.x86_64-linux.default ];
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

  fonts.packages = with pkgs; [
    fira-code
    # (nerdfonts.override { fonts = [ "FiraCode" ]; })
    nerd-fonts.fira-code
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
    autoUpgrade.enable = true;
    autoUpgrade.allowReboot = true;
    autoUpgrade.channel = "https://nixos/channels/nixos-24.05";
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
  };


  programs = {
    dconf.enable = true;
    zsh.enable = true;
    fish.enable = true;
    hyprland.enable = true;
    # hyprland.withUWSM = true;
    gamemode.enable = true;
    gamescope.enable = true;
    gamescope.capSysNice = true;
    gamescope.args = [
      "--expose-wayland"
      # "--backend wayland"
      # "--hdr-enabled"
      # "--immediate-flips"
      "-W 3840"
      "-H 2160"
      "-w 3840"
      "-h 2160"
      # "-b"
      "-r 144"
      "-o 144"
      # "--adaptive-sync"
    ];
    hyprlock.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
