{ config, pkgs, ...}:
{
  programs.nushell = {
    enable = true;
    extraConfig = ''
      $env.config = {
        show_banner: false,
        # shell_integration = true
      }
      '';
    # envFile = ''
      
    # '';
    shellAliases = config.home.shellAliases;
  };
}
