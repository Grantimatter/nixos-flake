[
  (_self: super: {
    formats = super.formats // {
      ron = import ./ron.nix { inherit (super) lib pkgs; };
    };
  })
  (_self: super: {
    opencode-monitor = super.python3Packages.buildPythonPackage rec {
      pname = "opencode-monitor";
      version = "1.0.4";
      format = "pyproject";
      src = super.fetchFromGitHub {
        owner = "Shlomob";
        repo = "ocmonitor-share";
        rev = "d91e733";
        hash = "sha256-iBPgXgqMd7dOUvG8rlN8xXGnr1KscXbqOQCVGRDCAms=";
      };
      propagatedBuildInputs = with super.python3Packages; [
        click
        rich
        pydantic
        toml
        pyyaml
      ] ++ [ super.python3Packages."prometheus-client" ];
      nativeBuildInputs = with super.python3Packages; [
        setuptools
        wheel
      ];
      doCheck = false;
      meta.mainProgram = "ocmonitor";
    };
  })
]
