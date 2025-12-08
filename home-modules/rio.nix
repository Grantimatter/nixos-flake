let
  catppuccin-theme = builtins.fetchurl {
    name = "catppuccin-mocha";
    url = "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/refs/heads/master/rio/Catppuccin%20Mocha.toml";
    sha256 = "0r3x39g3fzkcagvrs0kmwns7r0nr1h97sdlssniznw9qrcx02g16";
  };
in
{
  home.file.".config/rio/themes/catppuccin-mocha.toml".source = catppuccin-theme;
  programs.rio = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
      fonts.size = 22;
      fonts.weight = 1600;
      fonts.family = "Fira Code";
    };
  };
}
