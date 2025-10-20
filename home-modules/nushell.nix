{ pkgs, lib, catppuccin, ... }:
{
  programs.nushell = {
    enable = true;

    settings = {
      show_banner = false;
      buffer_editor = "hx";
      completions = {
        case_sensitive = false;
        quick = true;
        partial = true;
        algorithm = "fuzzy";
        external = {
          enable = true;
          max_results = 200;
        };
      };
    };

    configFile.text = ''
      $env.LS_COLORS = (vivid generate catppuccin-${catppuccin.flavor})
      $env.SHELL = "nu"

      $env.config.keybindings ++= [
        {
          name: open-editor
          modifier: control
          mode: [emacs, vi_normal, vi_insert]
          keycode: char_h
          event: { send: OpenEditor }
        }
      ];

      def create_left_prompt [] {
          starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
      }
      # def create_left_prompt [] {
      #     ^starship prompt --profile vi_insert
      # }

      # Use nushell functions to define your right and left prompt
      $env.PROMPT_COMMAND = { || create_left_prompt }

      # The prompt indicators are environmental variables that represent
      # the state of the prompt
      # $env.PROMPT_INDICATOR = ""
      $env.PROMPT_INDICATOR_VI_INSERT = ^starship module custom.nushell_vi_insert
      $env.PROMPT_INDICATOR_VI_NORMAL = ^starship module custom.nushell_vi_normal
      $env.PROMPT_MULTILINE_INDICATOR = "::: "

      # $env.TRANSIENT_PROMPT_COMMAND = ""
      # $env.TRANSIENT_PROMPT_INDICATOR = ""
      # $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = ""
      # $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = ""
      # $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = ""
      # $env.TRANSIENT_PROMPT_COMMAND_RIGHT = ^starship module time

      $env.CARAPACE_BRIDGES = 'fish,bash'
      '';

    shellAliases = {
      vi = "hx";
      vim = "hx";
      nano = "hx";
    };
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
