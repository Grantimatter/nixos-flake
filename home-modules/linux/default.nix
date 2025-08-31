{ pkgs, ...}:
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

  programs.obsidian.enable = true;

  services.spotifyd.enable = true;
  services.udiskie = {
    enable = true;
  };

  home.packages = with (pkgs); [
    libreoffice
    dmenu
    kdePackages.spectacle
    prismlauncher
    webcord-vencord
    discord
    vlc
    spotify
    spotify-player
    blender
    gimp
    wl-clipboard-rs
  ];

}
