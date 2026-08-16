{ pkgs, ...}:
{
  programs.onlyoffice.enable = true;

  programs.vesktop = {
    enable = true;
  };

  programs.obsidian.enable = true;

  services.udiskie = {
    enable = true;
  };
  services.gnome-keyring.enable = true;

  home.packages = with (pkgs); [
    libreoffice
    dmenu
    kdePackages.spectacle
    prismlauncher
    revolt-desktop
    vlc
    loupe
    spotify
    blender
    gimp
    inkscape
    wl-clipboard-rs
    signal-cli
  ];

}
