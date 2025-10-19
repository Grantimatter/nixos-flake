{ config, osConfig, pkgs, ... }:
let
  inherit (osConfig.networking) hostName;
  inherit (pkgs.stdenv) isLinux;
  inherit (config.home) username;
  inherit (osConfig.users) defaultUserShell;

  homeSwitch = "home-manager switch --flake '/home/${username}/nixos-flake/#${username}@${hostName}'";
  nixosSwitch = "sudo nixos-rebuild switch --flake '/home/${username}/nixos-flake/#${hostName}'";
in
{
  home = {
    shellAliases = {
      inherit homeSwitch;
      cat = "bat -p";
      # direnv-init = ''echo "use flake" >> .envrc; direnv allow'';
      top = "btm";
      btop = "btm";
      cd = "z";
      nixshell = "nix-shell -c ${defaultUserShell}";
      nixdev = "nix develop -c ${defaultUserShell}";
      tree = "erd --layout inverted --icons --human";
    } // (
      if isLinux then
        { inherit nixosSwitch; }
      else { }
    );

    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
      SOPS_AGE_KEY_FILE = config.xdg.configHome + "/sops/keys/age/keys.txt";
    };
  };
} 
