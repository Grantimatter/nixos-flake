{ inputs, lib, modulesPath, pkgs, ... }:
let
  inherit (lib) attrValues;
  systemPackages = attrValues {
    inherit (pkgs)
      # Hyprland
      kitty
      egl-wayland
      hyprpaper
      eww-wayland

      dolphin

      # Core
      bash
      zsh
      nnn
      coreutils
      usbutils
      home-manager
      ;
  };
in
{
  time.timeZone = "US/Central";
  i18n.defaultLocale = "en_US.UTF-8";
  virtualisation.docker.enable = true;
  console.keyMap = "us";
  systemd.services.upower.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    #../overlays
  ];

  nixpkgs.config = import ../nixpkgs-config.nix;

  environment = {
    pathsToLink = [ "/share/zsh" ];
    inherit systemPackages;
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
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
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

  users.defaultUserShell = pkgs.zsh;

  users.users.grant = {
    isNormalUser = true;
    home = "/home/grant";
    description = "Grant";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    initialPassword = "password";
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFY4/o4gfaJwr/B0+aB51QwiOI4jGCYodnCWM7Pj8iYH grant wiswell@Grant-Desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMpXeGgPkUi9Vfb3LBinNk03/x07y4pYoHcRWcReZ4E grant@wsl"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDMez1O0MFXBZS1vQ6lYBb4SiGZwmlDwMzeJtdXIQLu grant@acer-laptop"
    ];
  };

  security = {
    rtkit.enable = true;

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
    };

    blueman.enable = true;
    thermald.enable = true;
    upower.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
    displayManager.sddm.enable = true;
  };

  programs = {
    dconf.enable = true;
    zsh.enable = true;
    hyprland.enable = true;
    waybar.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
