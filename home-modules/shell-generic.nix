{ config, osConfig, pkgs, ... }:
let
  inherit (osConfig.networking) hostName;
  inherit (pkgs.stdenv) isLinux;
  inherit (config.home) username;

  homeSwitch = "home-manager switch --flake '/home/${username}/nixos-flake/#${username}@${hostName}'";
  nixosSwitch = "sudo nixos-rebuild switch --flake '/home/${username}/nixos-flake/#${hostName}'";
in
{
  home = {
    packages = [ pkgs.powershell ];
    shellAliases = {
      inherit homeSwitch;

      vim = "nvim";
      direnv-init = ''echo "use flake" >> .envrc'';
      ".." = "cd ..";
      "..." = "cd ../..";
      top = "btm";
      btop = "btm";
      ls = "eza";
      cat = "bat -p";
      tree = "erd --layout inverted --icons --human";
      grep = "rg";
      cd = "z";
      nixshell = "nix-shell -c zsh";
      nixdev = "nix develop -c zsh";
    } // (
      if isLinux then
        { inherit nixosSwitch; }
      else { }
    );

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SOPS_AGE_KEY_FILE = config.xdg.configHome + "/sops/keys/age/keys.txt";
    };
  };

  xdg.configFile."powershell/Microsoft.PowerShell_profile.ps1".text = ''
    Invoke-Expressin (&staship init powershell)
    Set-PSReadlineOption -EditMode Vi -ViModeIndicator Cursor
  '';
} 
