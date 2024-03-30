{pkgs, ...}:
{
  imports = [
    ./hardware-configuration.nix
    ../wsl/default.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  environment.systemPackages = [
    pkgs.arion
  ];

  virtualization.docker.enable = true;

  users.extraUsers.homelab.extraGroups = ["docker"];
}
