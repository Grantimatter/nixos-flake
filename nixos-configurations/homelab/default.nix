{ config, inputs, lib, pkgs, modulesPath, ...}:
{
  imports = [
    ../wsl/default.nix
    inputs.sops-nix.nixosModules.default
    inputs.arion.nixosModules.arion
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "homelab";

  environment.systemPackages = [
    pkgs.arion
  ];

  sops.secrets.homelab-credentials = {
    name = "homelab-credentials.yaml";
    owner = "homelab";
    group = "homelab";
    sopsFile = ../../sops/homelab-credentials;
  };

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
