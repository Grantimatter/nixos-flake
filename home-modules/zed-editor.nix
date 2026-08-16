{ config, lib, pkgs, inputs, ... }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in {
  programs.zed-editor = {
    enable = true;

    package = pkgs.symlinkJoin {
      name = "zed-editor-wrapped";
      paths = [
        pkgs-unstable.zed-editor
        (pkgs.writeShellScriptBin "zed" ''
          if [ -f /run/secrets/opencode-go-key ]; then
            export OPENCODE_API_KEY="$(cat /run/secrets/opencode-go-key)"
          fi
          if [ -f /run/secrets/openrouter-key ]; then
            export OPENROUTER_API_KEY="$(cat /run/secrets/openrouter-key)"
          fi
          exec ${pkgs-unstable.zed-editor}/bin/zed "$@"
        '')
      ];
      ignoreCollisions = true;
    };

    # package = pkgs-unstable.zed-editor;

    extensions = [
      "catppuccin-icons"
      "nix"
      "toml"
      "html"
    ];

    userSettings = {
      agent_servers = {
        mistral-vibe = { type = "registry"; };
        qwen-code = { type = "registry"; };
        github-copilot-cli = { type = "registry"; };
        opencode = { type = "registry"; };
        claude-acp = { type = "registry"; };
      };

      agent = {
        default_model = {
          provider = "opencode";
          model = "deepseek-v4-flash-free";
        };
        favorite_models = [];
        model_parameters = [];
        tool_permissions = {
          default = "confirm";
        };

      };

      opencode = {
        favorite_config_option_values = {
          model = [
            "opencode/deepseek-v4-flash-free"
            "opencode-go/minimax-m2.7"
            "opencode-go/glm-5.1"
            "opencode-go/kimi-k2.6"
            "opencode-go/deepseek-v4-pro"
            "opencode/nemotron-3-super-free"
          ];
        };
        type = "registry";
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      helix_mode = true;
      ui_font_size = 16;
      buffer_font_family = "FiraCode Nerd Font Mono";
      buffer_font_size = 15;

      # theme is handled by the catppuccin module
      # icon_theme is handled by the catppuccin module

      language_models = {
        opencode = {
          show_zen_models = true;
          show_go_models = true;
          show_free_models = true;
        };
      };
    };
  };
}
