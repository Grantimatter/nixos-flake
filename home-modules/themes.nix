{ catppuccin, inputs, ... }:
let
  catppuccin-obs = builtins.fetchGit {
    url = "https://github.com/catppuccin/obs";
    rev = "58a80435caf1ff4f62b94592f508fba4c3776c97";
  };
  catppuccin-cosmic = builtins.fetchGit {
    url = "https://github.com/catppuccin/cosmic-desktop";
    rev = "95e81098042dd2102f0b258f6990f886c5759692";
  };
  cosmic-theme = "catppuccin-${catppuccin.flavor}-${catppuccin.accent}+round.ron";
in
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  catppuccin = {
    enable = true;
    cursors.enable = true;
    flavor = catppuccin.flavor;
    accent = catppuccin.accent;

    atuin.enable = false;
    starship.enable = true;
  };

  qt = {
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };

  # Setup manual config files

  ## OBS
  home.file.".config/obs-studio/themes".source = "${catppuccin-obs}/themes";
  home.file.".config/obs-studio/themes".recursive = true;

  ## Cosmic
  home.file.".config/cosmic/com.system76.CosmicTheme.Dark/v1/${cosmic-theme}".source =
    "${catppuccin-cosmic}/themes/cosmic-settings/${cosmic-theme}";
}
