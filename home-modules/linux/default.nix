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
      joplin-desktop
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
