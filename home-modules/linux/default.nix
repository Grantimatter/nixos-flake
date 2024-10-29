{ lib, pkgs, ...}:
let
  inherit (lib) attrValues;
  
  packages = attrValues {
    inherit (pkgs)
      libreoffice
      dmenu
      spectacle
 
      prismlauncher
#      webcord-vencord
      # vesktop
      discord
      vlc
      spotify
      blender
      joplin-desktop
    ;
  };
in
{
  programs.firefox.enable = true;

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
