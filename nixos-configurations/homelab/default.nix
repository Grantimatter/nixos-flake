{ config, inputs, lib, pkgs, ...}:
{
  imports = [
    ../wsl/default.nix
    inputs.sops-nix.nixosModules.default
    inputs.arion.nixosModule.arion
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

  virtualisation.arion = {
    backend = "docker";
    projects.homelab = {
      serviceName = "homelab";
      settings = {
        imports = [ ./arion-compose.nix ];
      };
    };
  };

  users.extraUsers.homelab.extraGroups = ["docker"];
}
