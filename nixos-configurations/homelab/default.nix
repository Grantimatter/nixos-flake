{ config, inputs, lib, pkgs, ...}:
{
  imports = [
    ../wsl/default.nix
    inputs.sops-nix.nixosModules.default
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "homelab";

  users.users.homelab = {
    isNormalUser = true;
    home = "/home/homelab";
    description = "Home Lab Server";
    extraGroups = [ "docker" ];
    initialPassword = "password";
  };

  users.extraUsers.homelab.extraGroups = ["docker"];
}
