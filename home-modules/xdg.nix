{ config, ... }:
let
  inherit (config.xdg)
    cacheHome
    configHome
    dataHome
    ;
in
{
  xdg = {
    enable = true;
  };

  home = {
    sessionVariables = {

      # $HOME/.rustup
      RUSTUP_HOME = "${dataHome}/rustup";

      # $HOME/.cargo
      CARGO_HOME = "${dataHome}/cargo";

      # $HOME/.nv
      CUDA_CACHE_PATH = "${cacheHome}/nv";

      # $HOME/.docker
      DOCKER_CONFIG = "${configHome}/docker";
    };
  };
}
