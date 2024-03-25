{ ezModules, osConfig, ... }:
{
  imports = [
  ];

  programs.ssh.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  home = {
    username = "root";
    stateVersion = "23.11";
    homeDirectory = osConfig.users.users.root.home;
  };
}
