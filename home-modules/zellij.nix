{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    exitShellOnExit = true;

    settings.keybinds.normal._children = [
      {
        bind = {
          _args = [ "Ctrl Shift e" ];
          NewPane = [ "Down" ];
        };
      }
      {
        bind = {
          _args = [ "Ctrl Shift o" ];
          NewPane = [ "Right" ];
        };
      }
      {
        bind = {
          _args = [ "Ctrl Alt Right" ];
          MovePane = [ "Right" ];
        };
      }
      {
        bind = {
          _args = [ "Ctrl Alt Left" ];
          MovePane  = [ "Left" ];
        };
      }
      {
        bind = {
          _args = [ "Ctrl Alt Up" ];
          MovePane  = [ "Up" ];
        };
      }
      {
        bind = {
          _args = [ "Ctrl Alt Down" ];
          MovePane  = [ "Down" ];
        };
      }
      {
        bind = {
          _args = [ "Ctrl Tab" ];
          GoToNextTab = {};
        };
      }
      {
        bind = {
          _args = [ "Ctrl Shift Tab" ];
          GoToPreviousTab = {};
        };
      }
      {
        bind = {
          _args = [ "Ctrl Shift w" ];
          CloseTab = {};
        };
      }
      {
        bind = {
          _args = [ "Ctrl Shift t" ];
          NewTab = {
            cwd = "~/";
          };
        };
      }
      {
        bind = {
          _args = [ "Ctrl Alt l" ];
          Resize = [ "Left" ];
        };
      }
      {
        bind = {
          _args = [ "Ctrl Alt '" ];
          Resize = [ "Right" ];
        };
      }
      {
        bind = {
          _args = [ "Ctrl Alt y" ];
          Resize = [ "Up" ];
        };
      }
      {
        bind = {
          _args = [ "Ctrl Alt u" ];
          Resize = [ "Down" ];
        };
      }
      {
        bind = {
          _args = [ "Ctrl Shift f" ];
          TogglePaneFrames = [];
        };
      }
    ];

    settings.show_startup_tips = false;
    settings.default_layout = "minimal";
    settings.pane_frames = true;
    settings.copy_on_select = false;

    layouts.minimal.layout._children = [
      {
        pane = {
          size = 1;
          borderless = true;
          plugin.location = "zellij:compact-bar";
        };
      }
      {
        pane = {
          size = "100%";
          # borderless = true;
        };
      }
    ];    

    # layouts = {
    #   default = {
    #     layout = {
    #       _children = [
    #         {
    #           default_tab_template = {
    #             pane = {
    #               size = 1;
    #               borderless = true;
    #             };
    #           };
    #         }
    #         {
    #           new_tab_template = {
    #             pane = {
    #               size = 1;
    #               borderless = true;
    #             };
    #           };
    #         }
    #         # {
    #         #   pane_template = {
    #         #     # name = "pane-bl";
    #         #     size = 1;
    #         #     borderless = true;
    #         #   };
    #         # }
    #       ];
    #     };
    #   };
    # };
  };
}
