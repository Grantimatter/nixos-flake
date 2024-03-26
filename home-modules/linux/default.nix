{ lib, pkgs, ...}:
let
  inherit (lib) attrValues;
  
  packages = attrValues {
    inherit (pkgs)
      libreoffice
      firefox
      discord
      steam
      thunderbird
      vlc
    ;
  };
in
{
  home = {
    inherit packages;
  };
}
