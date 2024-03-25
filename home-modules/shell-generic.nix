{ config, osConfig, pkgs, ...}:
let
  inherit (osConfig.networking) hostName;
  inherit (pkgs.stdenv) isLinux;
  inherit (config.home) username;

  homeSwitch = "home-manager switch --flake '.#${username}@${hostName}'";
  nixosSwitch = "nixos-rebuild switch --flake '.#${hostName}'";
in
{
  home = {
    packages = [ pkgs.powershell ];
    shellAliases = {
      inherit homeSwitch;

      vim = "nvim";
      ".." = "cd ..";
      "..." = "cd ../..";
      } // (
        if isLinux then
          { inherit nixosSwitch; }
	else {}
      );

      sessionVariables = {
	EDITOR = "nvim";
	VISUAL = "nvim";
      };
    };
}
