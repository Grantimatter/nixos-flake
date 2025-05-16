{ catppuccin, inputs, ...}:
let
  catppuccin-obs = builtins.fetchGit { 
    url = "https://github.com/catppuccin/obs";
    rev = "58a80435caf1ff4f62b94592f508fba4c3776c97";
  };
in
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];


  catppuccin = {
    enable = true;
    cursors.enable = true;
    flavor = catppuccin.flavor;
    accent = catppuccin.accent;

    gtk.enable = true;
    gtk.icon.enable = false;

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
}
