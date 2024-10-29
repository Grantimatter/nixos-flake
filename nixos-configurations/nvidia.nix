{ config, inputs, lib, modulesPath, pkgs,  ... }:
{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

}
