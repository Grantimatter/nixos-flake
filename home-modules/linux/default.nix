{ lib, pkgs, ...}:
let
  inherit (lib) attrValues;
  
  packages = with (pkgs); [
    libreoffice
    dmenu
    kdePackages.spectacle
    prismlauncher
    webcord-vencord
    vesktop
    discord
    vlc
    spotify
    blender
    gimp
    wl-clipboard-rs
    superfile
  ];
in
{
  programs.firefox = {
    enable = true;
    policies = {
      BlockAboutConfig = true;
      ManualAppUpdateOnly = true;
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles = {
      
    };
  };

  services.spotifyd.enable = true;

  home = {
    inherit packages;
  };
}
