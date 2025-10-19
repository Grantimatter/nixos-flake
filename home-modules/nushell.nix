{ catppuccin, ... }:
{
  programs.nushell = {
    enable = true;

    settings = {
      show_banner = false;
      buffer_editor = "hx";
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

      # $env.TRANSIENT_PROMPT_COMMAND = ^starship module custom.nushell
      
      # $env.TRANSIENT_PROMPT_COMMAND = ""
      $env.TRANSIENT_PROMPT_INDICATOR = ""
      $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = ""
      $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = ""
      $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = ""
      $env.TRANSIENT_PROMPT_COMMAND_RIGHT = ^starship module time
      '';

    envFile.text = ''
      # mkdir ($nu.data-dir | path join "vendor/autoload")
      # starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
    '';
  };
}
