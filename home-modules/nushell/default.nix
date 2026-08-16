{ config, pkgs, lib, catppuccin, ... }:
let
  inherit (config.xdg)
    cacheHome
    configHome
    dataHome
    ;

  CARGO_HOME = "${dataHome}/cargo";
in
{
  programs.nushell = {
    enable = true;
    environmentVariables = {
      # $HOME/.rustup
      RUSTUP_HOME = "${dataHome}/rustup";

      # # $HOME/.cargo
      inherit CARGO_HOME;

      # $HOME/.nv
      CUDA_CACHE_PATH = "${cacheHome}/nv";

      # $HOME/.docker
      DOCKER_CONFIG = "${configHome}/docker";

      CATPPUCCIN_FLAVOR = catppuccin.flavor;
    };

    settings = {
      show_banner = false;
      buffer_editor = "hx";
      completions = {
        case_sensitive = false;
        quick = true;
        partial = true;
        algorithm = "fuzzy";
        external = {
          enable = true;
          max_results = 200;
        };
      };
    };

    configFile.source = ./config.nu;

    shellAliases = {
      vi = "hx";
      vim = "hx";
      nano = "hx";
      ht = "hermes --tui";
    };
    
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
