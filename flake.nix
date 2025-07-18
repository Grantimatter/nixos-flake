{
  description = "Nixos config flake";

  inputs = {
    # Nix Inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # Community Inputs
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musnix = {
      url = "github:musnix/musnix";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake
    { inherit inputs; }
    {
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

      perSystem = { pkgs, pkgs-stable, lib, system, ... }: {

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.sops-nix.overlays.default inputs.rust-overlay.overlays.default ];
          environment.systemPackages = [ pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default) ];
        };
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
