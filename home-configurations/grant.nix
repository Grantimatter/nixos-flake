{ pkgs, ... }:
{
  home = {
    username = "grant";
    stateVersion = "23.11";
    homeDirectory = "/home/grant";
  };

  programs.git = {
    enable = true;
    userName = "Grant Wiswell";
    userEmail = "wiswellgrant@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.nnn.enable = true;
  programs.zsh = {
    enable = true;
  };

  # Hyprland Settings
  #services.hyprpaper.enable = true;
  programs.kitty.enable = true;
  wayland.windowManager.hyprland.enable = true;
  home.sessionVariables.NIXOS_OZONE_WL = "1";
  wayland.windowManager.hyprland.systemd.variables = ["--all"];
  programs.wofi.enable = true;

  # Hyprland Config
  wayland.windowManager.hyprland.settings = {
    "$terminal" = "wezterm";
    "$fileManager" = "nnn";
    "$menu" = "wofi --show drun";

    "$mod" = "SUPER";
    "windowrulev2" = "supressevent maximize, class:.*";
    
    bind = [
      "$mod, F, exec, firefox"
      "$mod, Q, exec, $terminal"
      "$mod, C, killactive,"
      "$mod, E, exec, $fileManager"
      "$mod, V, togglefloating,"
      "$mod, R, exec, $menu"

      # Move focus with mod + arrow keys
      "ALT, N, movefocus, l"
      "ALT, O, movefocus, r"
      "ALT, I, movefocus, u"
      "ALT, E, movefocus, d"

      # Swap windows
      "ALTCTRL, N, swapwindow, l"
      "ALTCTRL, O, swapwindow, r"
      "ALTCTRL, I, swapwindow, u"
      "ALTCTRL, E, swapwindow, d"

      # Resize windows
      "ALT, L, resizeactive, -150 0"
      "ALT, \", resizeactive, 150 0"
      "ALT, U, resizeactive, 0 -150"
      "ALT, I, resizezctive, 0 150"

      "$mod, U, workspace, previous"
    ]
    ++ (
      # Workspaces
      # Binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
      builtins.concatLists (builtins.genList (i:
        let ws = i + 1;
        in [
          "$mod, code:1${toString i}, workspace, ${toString ws}"
          "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
        ]
      )
      9)
    );

    exec-one = [
      "waybar"
      #"hyprpaper"
    ];

    cursor = {
      no_hardware_cursors = true;
    };

    env = [
      "XCURSORSIZE,24"
      "HYPRCURSOR_SIZE,24"
      "SDL_VIDEODRIVER,wayland"
      "MOZ_ENABLE_WAYLAND,1"
      "NIXOS_OZONE_WL,1"
      
      # Nvidia env
      "LIBVA_DRIVER_NAME,nvidia"
      "XDG_SESSION_TYPE,wayland"
      "GBM_BACKEND,nidia-drm"
      "__GLX_VENDORLIBRARY_NAME,nvidia"
      "__GL_GSYNC_ALLOWED,1"
      "NVD_BACKEND,direct"
    ];

    general = {
      gaps_in = 6;
      gaps_out = 10;
      border_size = 1;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";

      allow_tearing = true;
      layout = "dwindle";
    };

    input = {
      force_no_accel = 1;
    };

    decoration = {
      rounding = 8;
      dim_inactive = true;
      dim_strength = 0.2;
      drop_shadow = 1;
      shadow_range = 20;
      shadow_render_power = 2;
      "col.shadow" = "rgba(00000044)";
      shadow_offset = "0 0";
      blur = {
        enabled = 1;
        size = 4;
        ignore_opacity = 1;
        xray = 1;
        new_optimizations = 1;
        noise = 0.03;
        conrtast = 1.0;
      };
    };

    dwindle = {
      pseudotile = 0;
      force_split = 2;
      preserve_split = 1;
      default_split_ratio = 1.3;
    };

    master = {
      new_is_master = false;
      new_on_top = false;
      no_gaps_when_only = false;
      orientation = "top";
      mfact = 0.6;
      always_center_master = false;
    };

    misc = {
      vfr = true;
      animate_maniual_resizes = true;
      force_default_wallpaper = 0;
    };
  };
  
}
