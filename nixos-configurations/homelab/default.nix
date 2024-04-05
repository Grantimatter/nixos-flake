{ config, inputs, lib, pkgs, modulesPath, ...}:
{
  imports = [
    ../wsl/default.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "homelab";

  environment.systemPackages = [
    pkgs.arion
  ];

  users.users.homelab = {
    isNormalUser = true;
    home = "/home/homelab";
    description = "Home Lab Server";
    extraGroups = [ "docker" ];
    initialPassword = "password";
  };

  virtualisation.docker.enable = true;

  users.extraUsers.homelab.extraGroups = ["docker"];
}
