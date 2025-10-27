{
  description = "Nixos config flake";

  inputs = {
    # Nix Inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };


    # Community Inputs
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    wired.url = "github:Toqozz/wired-notify";

    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    eden = {
      url = "github:grantimatter/eden-flake";
    };

    catppuccin.url = "github:catppuccin/nix";

    # Rust Overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musnix = {
      url = "github:musnix/musnix";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.ez-configs.flakeModule
      ];

      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      ezConfigs = {
        root = ./.;
        globalArgs = { inherit inputs; };
        earlyModuleArgs = {
          catppuccin = {
            flavor = "mocha";
            accent = "red";
            secondary = "pink";
          };
        };
      };

      perSystem =
        {
          pkgs,
          pkgs-stable,
          pkgs-master,
          lib,
          system,
          ...
        }:
        {

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = import ./pkgs/default.nix ++ [
              inputs.sops-nix.overlays.default
              inputs.rust-overlay.overlays.default
            ];
            environment.systemPackages = [
              pkgs.rust-bin.selectLatestNightlyWith
              (toolchain: toolchain.default)
            ];
          };

          formatter = pkgs.nixpkgs-fmt;
          
          devShells.default = pkgs.mkShell {
            name = "default-shell";
            packages = lib.attrValues {
              inherit (pkgs)
                age
                cloudflared
                nixos-rebuild
                sops
                ssh-to-age
                ;
            };
          };
        };
    };
}
