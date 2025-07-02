{ lib, pkgs, ...}:
let
  inherit (lib) attrValues;
  
  wrapElectronApp = appName: appPkg: pkgs.symlinkJoin {
    name = "${appName}-wrapped";
    paths = [ appPkg ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/${appName} \
        --add-flags "--enable-features=WaylandLinuxDrmSyncobj"
    '';
  };
  
  packages = with (pkgs); [
    libreoffice
    dmenu
    kdePackages.spectacle
    prismlauncher
    webcord-vencord
    discord
    catppuccin-discord
    # vesktop
    vlc
    # spotify
    # spotify-player
    # spotify-qt
    blender
    gimp
    wl-clipboard-rs
  ] ++ [
    # (wrapElectronApp "vesktop" pkgs.vesktop)
    (wrapElectronApp "obsidian" pkgs.obsidian)
    (wrapElectronApp "spotify" pkgs.spotify)
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

  programs.onlyoffice.enable = true;

  programs.vesktop = {
    enable = true;
  };

  programs.thunderbird = {
    enable = true;
    profiles = {
      
    };
  };

  services.spotifyd.enable = true;
  services.udiskie = {
    enable = true;
  };

  home = {
    inherit packages;
  };
}
