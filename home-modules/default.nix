{ ezModules, config, lib, pkgs, inputs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system; config.allowUnfree = true; };
in
{
  imports = lib.attrValues {
    inherit (ezModules)
      wezterm
      helix
      shell-generic
      shell-utils
      eza
      nushell
      ghostty
      rio
      zsh
      fish
      kitty
      xdg
      linux
      eww
      hyprland
      themes
      zen-browser
      direnv
      zellij
      ;
  };

  home = {
    packages = [
      pkgs.bitwarden-cli
      pkgs.zettlr
      pkgs-unstable.zed-editor
    ];

    activation.installOpencodeHoncho = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if ! grep -q "@honcho-ai/opencode-honcho" "$HOME/.config/opencode/opencode.json" 2>/dev/null; then
        echo "home-manager: installing opencode honcho plugin..."
        OPENCODE="$HOME/.nix-profile/bin/opencode"
        if [ -x "$OPENCODE" ]; then
          "$OPENCODE" plugin "@honcho-ai/opencode-honcho" --global 2>&1 || echo "home-manager: opencode plugin install failed (will retry next switch)"
        else
          echo "home-manager: opencode not found at $OPENCODE, skipping"
        fi
      fi
    '';
  };


  nixpkgs.config = import ../nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ../nixpkgs-config.nix;
  programs.home-manager.enable = true;
}
