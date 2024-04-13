{ config, inputs, lib, modulesPath, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../nvidia.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.tailscale.enable = true;
  services.xserver = {
    enable = true;
#    displayManager.gdm.enable = true;
#    desktopManager.gnome.enable = true;
#    desktopManager.xterm.enable = false;
    displayManager.lightdm.enable = true;
    displayManager.defaultSession = "none+i3";
    windowManager.i3.enable = true;
    excludePackages = [ pkgs.xterm ];
    layout = "us";
    xkbVariant = "";
  };

  services.autorandr = {
    enable = true;
    profiles = {
      "tri-desktop" = {
        fingerprint = {
	  DP-0 = "00ffffffffffff004c2da00c303531331e1a0104a5351e78227dd1a45650a1280f5054bfef80714f81c0810081809500a9c0b3000101023a801871382d40582c4500132b2100001e000000fd00324b1e5111000a202020202020000000fc00533234453435300a2020202020000000ff0048434c483730353833390a202001f7020306814190023a801871382d40582c4500132b2100001e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000073";
          DP-2 = "00ffffffffffff004c2da00c303531331e1a0104a5351e78227dd1a45650a1280f5054bfef80714f81c0810081809500a9c0b3000101023a801871382d40582c4500132b2100001e000000fd00324b1e5111000a202020202020000000fc00533234453435300a2020202020000000ff0048434c483730353831310a20200101020306814190023a801871382d40582c4500132b2100001e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000073";
	  DP-4 = "00ffffffffffff004c2d7771505a43302a200104b54024783a6115ad5045a4260e5054bfef8081c0810081809500a9c0b300714f01014dd000a0f0703e803020350078682100001a000000fd081e901e458f000a202020202020000000fc004c53323841473730304e0a2020000000ff0048434a544130313738350a2020027602031ef1465f103f0403762309070783010000e305c000e6060501615a00023a801871382d40582c450078682100001e565e00a0a0a029503020350078682100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e97012790000030150512c0288ff0e2f02f7801f006f0859004b00070097e20008ff099f0007803f009f052800020004006ec20008ff099f002f801f009f055400020004006f7e00087f074f0007801f0037042c001e0007000000000000000000000000000000000000000000000000000000000000000000000000000000bd90";
	};
	config = {
	  DP-0 = {
	    enable = true;
	    primary = false;
	    position = "0x0";
	    rotate = "right";
	    mode = "1920x1080";
	    rate = "60.00";
	  };
	  DP-2 = {
	    enable = true;
	    primary = false;
	    position = "4920x0";
	    rotate = "left";
	    mode = "1920x1080";
	    rate = "60.00";
	  };
	  DP-4 = {
	    enable = true;
	    primary = true;
	    rotate = "normal";
	    position = "1080x0";
	    mode = "3840x2160";
	    rate = "143.86";
	  };
	};
#	hooks.postswitch = readFile ./tri-desktop-postswitch.sh;
      };
    };
  };

  networking = {
    hostName = "nixos-desktop";
    networkmanager.enable = true;
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    settings.trusted-users = [
      "root"
    ];

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  environment.systemPackages = lib.attrValues {
    inherit (pkgs)
      git
      neovim
      ;
  };

  programs = {
    steam.enable = true;
  };

  system.stateVersion = "23.11";
}
