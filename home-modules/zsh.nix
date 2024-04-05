{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    history = {
      ignoreSpace = true;
      path = "${config.xdg.cacheHome}/zsh/history";
    };
  };
}
