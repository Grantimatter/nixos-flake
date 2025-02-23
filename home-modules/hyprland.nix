{ config, pkgs, lib, ...}:
let
  theme_config = builtins.readFile (
      builtins.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/hyprland/refs/heads/main/themes/mocha.conf";
        sha256 = "4b154dbd96637ee3c0db207dc40d041c712713d788409005541214b838922314";
      });
  theme_name = "catppuccin-mocha-maroon";
  theme_pkg = "${pkgs.catppuccin-cursors.mochaMaroon}";
  cursor_size = "38";
  wallpaper = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/wallpapers/nixos-wallpaper-catppuccin-mocha.png";
    sha256 = "7e6285630da06006058cebf896bf089173ed65f135fbcf32290e2f8c471ac75b";
  };
  wallpaper1 = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/refs/heads/main/os/nix-black-4k.png";
    sha256 = "1d165878a0e67c0e7791bddf671b8d5af47c704f7ab4baea3d9857e3ecf89590";
  };
in
{
  wayland.windowManager.hyprland.enable = true;
  home.sessionVariables.NIXOS_OZONE_WL = "1";
  wayland.windowManager.hyprland.systemd.variables = ["--all"];
  programs.wofi.enable = true;
  programs.mangohud.enable = true;

  # wayland.windowManager.hyprland.extraConfig = theme_config;

  # Hyprland Config

  wayland.windowManager.hyprland.importantPrefixes = [
    "#Catppuccin Theme"
    "$"
    "bezier"
    "name"
    "source"
  ];
  
  wayland.windowManager.hyprland.settings = {
    # inherit theme_config;
    "#Catppuccin Theme" = theme_config;
    "$theme" = "${theme_name}";
    "$terminal" = "kitty";
    "$fileManager" = "nnn";
    "$menu" = "wofi --show drun";

    "$mod" = "SUPER";
    "$shiftmod" = "SUPER_SHIFT";

    windowrulev2 = [
      "suppressevent maximize, class:.*"
      "tag +term, class:(kitty)"
      "tag +term, class:(wezterm)"
      # "tag +opac, class:(steam)"
      "tag +opac, class:(discord)"
      "opacity 0.9 override 0.70 override, tag:term"
      "opacity 0.9 override 0.6 override, tag:opac"
      # xwaylandvideobridge
      "opacity 0.0 override, class:^(xwaylandvideobridge)$"
      "noanim, class:^(xwaylandvideobridge)$"
      "noinitialfocus, class:^(xwaylandvideobridge)$"
      "maxsize 1 1, class:^(xwaylandvideobridge)$"
      "noblur, class:^(xwaylandvideobridge)$z"
    ];

    monitor = ", highres@highrr, auto, 1, bitdepth, 10, vrr, 1";
    
    bind = [
      "$mod, F, fullscreen, 1"
      ", F11, fullscreen, 0"
      "$mod, Q, exec, $terminal"
      "$mod, C, killactive,"
      "$mod, M, exit"
      "$mod, E, exec, $fileManager"
      "$mod, V, togglefloating,"
      "$mod, R, exec, $menu"

      "$shiftmod, S, exec, hyprshot -m region --clipboard-only"
      "$shiftmod, W, exec, hyprshot -m window --clipboard-only"
      "$shiftmod, M, exec, hyprshot, -m output --clipboard-only"
      
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

      # Toggle Horizontal / Vertical Split
      "$mod, T, layoutmsg, togglesplit"

      # Resize windows
      "ALT, L, resizeactive, -200 0"
      "ALT, apostrophe, resizeactive, 200 0"
      "ALT, U, resizeactive, 0 100"
      "ALT, Y, resizeactive, 0 -100"

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

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    exec-once = [
      #"waybar"
      "hyprpaper"
      # "systemctl --user start plasma-polkit-agent"
      "systemctl --user start polkit-agent"
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "dbus-update-activation-environment --systemd --all"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    ];

    cursor = {
      no_hardware_cursors = true;
    };

    env = [
      "MOZ_ENABLE_WAYLAND,1"
      "NIXOS_OZONE_WL,1"

      # Toolkit env
      "SDL_VIDEODRIVER,wayland"
      "GDK_BACKEND,wayland,x11"
      "GDK_SCALE,1.25"
      "CLUTTER_BACKEND,wayland"

      # XDG env
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "XDG_SESSION_DESKTOP,Hyprland"
      
      # Nvidia env
      "GBM_BACKEND,nvidia-drm"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "LIBVA_DRIVER_NAME,nvidia"
      "__GL_GSYNC_ALLOWED,1"
      "__GL_VRR_ALLOWED,1"
      "NVD_BACKEND,direct"

      # Theme
      "HYPRCURSOR_THEME,$theme"
      "HYPRCURSOR_SIZE,${cursor_size}"
      "XCURSOR_THEME,$theme"
      "XCURSORSIZE,${cursor_size}"
    ];

    general = {
      gaps_in = 6;
      gaps_out = 10;
      border_size = 2;
      "col.active_border" = "$red $mauve 45deg";
      "col.inactive_border" = "rgba(595959aa)";

      allow_tearing = true;
      layout = "dwindle";
    };

    input = {
      sensitivity = 0.5;
      accel_profile = "flat";
    };

    xwayland = {
      force_zero_scaling = true;
      use_nearest_neighbor = false;
    };

    opengl = {
      nvidia_anti_flicker = true;
    };

    render = {
      explicit_sync = 0;
      direct_scanout = true;
    };
    
    decoration = {
      rounding = 8;
      dim_inactive = true;
      dim_strength = 0.15;
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
        contrast = 1.0;
      };
    };

    dwindle = {
      pseudotile = 0;
      force_split = 2;
      preserve_split = 1;
      default_split_ratio = 1.3;
    };

    master = {
      #new_is_master = false;
      new_on_top = false;
      no_gaps_when_only = false;
      orientation = "top";
      mfact = 0.6;
      always_center_master = false;
    };

    misc = {
      vfr = true;
      animate_manual_resizes = true;
      force_default_wallpaper = 0;
    };

    animations = {
      enabled = true;

      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, myBezier, popin 80%"
        "border, 1, 10, myBezier"
        "borderangle, 1, 8, myBezier"
        "fade, 1, 7, myBezier"
        "workspaces, 1, 6, myBezier"
      ];
    };
  };

  # Cursor Theme
  home.file.".local/share/icons/${theme_name}".source = "${theme_pkg}/share/icons/${theme_name}-cursors";

  # Wallpaper
  home.file.".local/share/wallpapers/wallpaper".source = "${wallpaper}";

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "${wallpaper}"
      ];

      wallpaper = [
        ",${wallpaper}"
      ];

      splash = false;
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";       # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session";    # lock before suspend.
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };

      listener = [
        {
          timeout = 150;                                    # 2.5min.
          "on-timeout" = "brightnessctl -s set 10";         # set monitor backlight to minimum, avoid 0 on OLED monitor.
          "on-resume" = "brightnessctl -r";                 # monitor backlight restore.
        }

        # {
        #   timeout = 300;                                    # 5min
        #   on-timeout = "loginctl lock-session";             # lock screen when timeout has passed
        # }
        # {
        #   timeout = 330;                                    # 5.5min
        #   on-timeout = "hyprctl dispatch dpms off";         # screen off when timeout has passed
        #   on-resume = "hyprctl dispatch dpms on";           # screen on when activity is detected after timeout has fired.
        # }
        # {
        #   timeout = 1800;                                  # 30min
        #   on-timeout = "systemctl suspend";                # suspend pc
        # }
      ];
    };
  };
}
