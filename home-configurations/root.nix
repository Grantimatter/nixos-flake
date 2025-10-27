{ osConfig, ... }:
{
  # programs.ssh.enable = true;

  home = {
    username = "root";
    stateVersion = "23.11";
    homeDirectory = osConfig.users.users.root.home;
  };
}
