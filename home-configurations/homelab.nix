{ ... }:
{
  home = {
    username = "homelab";
    stateVersion = "23.11";
    homeDirectory = "/home/homelab";
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user.name = "Grant Wiswell";
      user.email = "grantwiswell@proton.me";
    };
  };

  programs.zsh = {
    enable = true;
  };
}
