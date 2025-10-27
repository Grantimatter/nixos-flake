[
  (_self: super: {
    formats = super.formats // {
      ron = import ./ron.nix { inherit (super) lib pkgs; };
    };
  })
]
