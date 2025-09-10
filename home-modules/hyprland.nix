{ inputs, catppuccin, config, pkgs, lib, ...}:

let
  cursor_theme = "catppuccin-${catppuccin.flavor}-${catppuccin.accent}-cursors";
  cursor_size = 32;
  wallpaper = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/wallpapers/nixos-wallpaper-catppuccin-mocha.png";
    sha256 = "7e6285630da06006058cebf896bf089173ed65f135fbcf32290e2f8c471ac75b";
  };
in
{
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];

  # services.vicinae = {
  #   enable = true;
  #   autoStart = true;
  # };

  wayland.windowManager.hyprland.enable = true;
  home.sessionVariables.NIXOS_OZONE_WL = "1";
  # home.sessionVariables.ROFI_WAYLAND = "1";
  # wayland.windowManager.hyprland.systemd.variables = ["--all"];
  # programs.wofi.enable = true;

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    settings = {
      toggle_hud = "Shift_L+F12";
      no_display = true;
      
      cpu_temp = true;
      gpu_temp = true;
      throttling_status = true;

      procmem = true;
      procmem_shared = true;
      procmem_virt = true;
      ram = true;
      vram = true;
      gpu_core_clock = true;
      gpu_mem_clock = true;
      gpu_voltage = true;
      swap = true;
      resolution = true;
      show_fps_limit = true;

      io_read = true;
      io_write = true;

      frametime = true;

      arch = true;
      display_server = true;
      gamemode = true;
      wine = true;
    };
  };

  # wayland.windowManager.hyprland.extraConfig = theme_config;

  # Hyprland Config
  
  wayland.windowManager.hyprland.plugins = [
    # pkgs.hyprlandPlugins.hypr-dynamic-cursors
    pkgs.hyprlandPlugins.hy3
  ];

  wayland.windowManager.hyprland.importantPrefixes = [
    # "#Catppuccin Theme"
    "$"
    "bezier"
    "name"
    "source"
  ];
  
  wayland.windowManager.hyprland.settings = {
    "$terminal" = "uwsm-app -- ghostty";
    "$shell" = "fish";
    # Yazi using fish function (y)
    "$fileManager" = "uwsm-app -- cosmic-files";
    # "$menu" = "uwsm-app -- fuzzel --dpi-aware=yes --launch-prefix=\"uwsm-app -- \"";
    "$menu" = "uwsm-app -- vicinae";
    # "$run" = "uwsm-app fuzzel --";
    # "$window" = "";
    # "$window" = "rofi -show window";

    "$mod" = "SUPER";
    "$shiftmod" = "SUPER_SHIFT";

    "plugin:dynamic-cursors" = {
      mode = "tilt";
      rotate = {
        length = 16;
      };
      tilt = {
        limit = 5000;
        function = "negative_quadratic";
      };
      stretch = {
        limit = 3000;
        function = "quadratic";
      };
      shake = {
        enabled = true;
        nearest = true;
        effects = true;
        base = 4.0;
      };
      hyprcursor = {
        enabled = true;
        resolution = -1;
        fallback = "default";
      };
    };

    "plugin:hy3" = {
      no_gaps_when_only = 1;
    };

    debug = {
      full_cm_proto = true;
    };

    windowrulev2 = [
      "unset,class:^(UnrealEditor)$,title:^\w*$"
      "noinitialfocus,class:^(UnrealEditor)$,title:^\w*$"
      "noanim,class:^(UnrealEditor)$,title:^\w*$"
      "suppressevent maximize, class:.*"
      "tag +term, class:.*ghostty"
      "tag +term, class:.*wezterm"
      "tag +floating, class:.*Calculator"
      "tag +floating, title:.*clipse"
      "tag +floating, title:.*\(Bitwarden Password Manager\).*"
      "tag +floating, class:.*SimpleScan"
      "tag +floating, title:^(Save As)"
      "tag +floating, class:naps2"
      "tag +floating, class:it.mijorus.smile"
      # "tag +opac, class:(steam)"
      # "tag +opac, class:(discord)"
      "opacity 0.95 override 0.9 override, tag:term"
      "opacity 0.95 override 0.9 override, tag:opac"
      # xwaylandvideobridge
      "opacity 0.0 override, class:.*xwaylandvideobridge"
      "noanim, class:.*xwaylandvideobridge"
      "noinitialfocus, class:.*xwaylandvideobridge"
      "maxsize 1 1, class:.*xwaylandvideobridge"
      "noblur, class:.*xwaylandvideobridge"
      "float, tag:floating*"
      "size 622 652, title:.*clipse"
      "stayfocused, title:.*clipse"
      "opacity 0.8 override 0.75 override, title:.*clipse"
    ];

    monitor = [
      "DP-3, highres@highrr, auto, 1, vrr, 1, bitdepth, 10"
      # ", highres@highrr, auto, 1"
    ];
    
    bind = [
      "$mod, F, fullscreen, 1"
      ", F11, fullscreen, 0"
      "$mod, Q, exec, $terminal"
      "$mod, C, hy3:killactive,"
      "$shiftmod, M, exec, uwsm stop"
      "$shiftmod, E, exec, uwsm-app -- smile"
      "$mod, E, exec, $fileManager"
      "$shiftmod, F, togglefloating,"
      "$mod, R, exec, $menu"
      # "$mod, W, exec, $window"
      "$mod+CTRL, V, exec, $terminal --title=clipse -e clipse"
      "$mod, tab, hy3:togglefocuslayer"
      "$mod, P, exec, uwsm-app -- hyprpicker -a"

      "$mod, H, hy3:makegroup, h"
      "$mod, V, hy3:makegroup, v"
      "$mod, Z, hy3:makegroup, tab"

      "$shiftmod, S, exec, uwsm-app -- hyprshot -m region --clipboard-only"
      "$shiftmod, W, exec, uwsm-app -- hyprshot -m window --clipboard-only"
      "$shiftmod, M, exec, uwsm-app -- hyprshot -m output --clipboard-only"
      
      # Move focus with mod + NEIO
      "ALT, N, hy3:movefocus, l"
      "ALT, O, hy3:movefocus, r"
      "ALT, I, hy3:movefocus, u"
      "ALT, E, hy3:movefocus, d"
      # Move focus with mod + arrow keys
      "$mod, left, hy3:movefocus, l"
      "$mod, right, hy3:movefocus, r"
      "$mod, up, hy3:movefocus, u"
      "$mod, down, hy3:movefocus, d"

      # Move windows with NEIO
      "ALTCTRL, N, hy3:movewindow, l, once"
      "ALTCTRL, O, hy3:movewindow, r, once"
      "ALTCTRL, I, hy3:movewindow, u, once"
      "ALTCTRL, E, hy3:movewindow, d, once"

      # Move Monitors
      "ALTSHIFT, 1, hy3:movewindow, mon:0"
      "ALTSHIFT, 2, hy3:movewindow, mon:1"

      # Toggle Horizontal / Vertical Split
      "$mod, T, layoutmsg, togglesplit"

      # Resize windows
      "ALT, L, resizeactive, -200 0"
      "ALT, apostrophe, resizeactive, 200 0"
      "ALT, U, resizeactive, 0 -100"
      "ALT, Y, resizeactive, 0 100"

      "$mod, U, workspace, previous"
    ]
    ++ (
      # Workspaces
      # Binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
      builtins.concatLists (builtins.genList (i:
        let ws = i + 1;
        in [
          "$mod, code:1${toString i}, workspace, ${toString ws}"
          "$mod SHIFT, code:1${toString i}, hy3:movetoworkspace, ${toString ws}"
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
      "uwsm-app -- hyprpaper"
      # "uwsm-app -- clipse -listen"
      # "systemctl --user start plasma-polkit-agent"
      # "systemctl --user start polkit-agent"
      # "systemctl --user start clipse.service"
      "systemctl --user start hyprpolkitagent"
      # "systemctl --user enable --now clipse.service"
      "systemctl --user enable --now hypridle.service"
      "walker --gapplication-service"
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "dbus-update-activation-environment --systemd --all"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME"
    ];

    cursor = {
      no_hardware_cursors = 1;
    };

    env = [
      "MOZ_ENABLE_WAYLAND,1"

      # Electron
      "NIXOS_OZONE_WL,1"
      "ELECTRON_OZONE_PLATFORM_HINT,wayland"
      "ELECTRON_ENABLE_WAYLAND,1"

      # Toolkit env
      "SDL_VIDEODRIVER,wayland"
      "GDK_BACKEND,wayland,x11"
      # "GDK_THEME,${theme_name}"
      "CLUTTER_BACKEND,wayland"
      "QT_QPA_PLATFORM,wayland-egl"

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
      "HYPRCURSOR_THEME,${cursor_theme}"
      "HYPRCURSOR_SIZE,${toString(cursor_size)}"
      "XCURSOR_THEME,${cursor_theme}"
      # "XCURSOR_THEME,catppuccin-${catppuccin-home.flavor}-${catppuccin-home.accent}-cursors"
      
      # Scaling
      "GDK_SCALE,1"
      "GDK_DPI_SCALE,1"
      "QT_SCALE_FACTOR,1.25"
      "QT_AUTO_SCREEN_SCALE_FACTOR,0"
      "XCURSOR_SIZE,${toString(cursor_size)}"
      "XDG_SCALE_FACTOR,1"

      # # Extra
      # "_JAVA_AWT_WM_NONREPARENTING=1"
      # "WLR_NO_HARDWARE_CURSORS,1"
      # "__NV_PRIME_RENDER_OFFLOAD,1"
      # "__VK_LAYER_NV_optimus,NVIDIA_only"
      # "PROTON_ENABLE_NGX_UPDATER,1"
      "WLR_DRM_NO_ATOMIC,1"
      # "WLR_USE_LIBINPUT,1"
      # "__GL_MaxFramesAllowed,1"
      # "WLR_RENDERER_ALLOW_SOFTWARE,1"
    ];

    general = {
      gaps_in = 0;
      gaps_out = 0;
      border_size = 2;
      "col.active_border" = "\$${catppuccin.accent} \$${catppuccin.secondary} 45deg";
      "col.inactive_border" = "rgba(595959aa)";

      allow_tearing = true;
      layout = "hy3";
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
      direct_scanout = 2;
      cm_auto_hdr = 1;
    };
    
    decoration = {
      rounding = 0;
      dim_inactive = true;
      dim_strength = 0.05;
      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
      };
      blur = {
        enabled = 1;
        size = 8;
        ignore_opacity = 1;
        xray = false;
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
      # no_gaps_when_only = false;
      orientation = "top";
      mfact = 0.6;
      # always_center_master = false;
    };

    misc = {
      vfr = true;
      vrr = 1;
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

  # Wallpaper
  home.file.".local/share/wallpapers/wallpaper".source = "${wallpaper}";

  programs.fuzzel.enable = true;
  programs.hyprlock.enable = true;
  # programs.hyprlock.settings = {
    
  # };

  gtk = {
    enable = true;
  };

  services.clipse.enable = true;

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
          # before_sleep_cmd = "loginctl lock-session";    # lock before suspend.
          # after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };

      listener = [
        # {
        #   timeout = 150;                                  # 2.5min.
        #   "on-timeout" = "brightnessctl -s set 10";       # set monitor backlight to minimum, avoid 0 on OLED monitor.
        #   "on-resume" = "brightnessctl -r";               # monitor backlight restore.
        # }
        {
          timeout = 600;                                    # 10min
          on-timeout = "loginctl lock-session";             # lock screen when timeout has passed
        }

        # {
        #   timeout = 1800;                                   # 30min
        #   on-timeout = "hyprctl dispatch dpms off";         # screen off when timeout has passed
        #   on-resume = "hyprctl dispatch dpms on";           # screen on when activity is detected after timeout has fired.
        # }
        # {
        #   timeout = 1800;                                 # 30min
        #   on-timeout = "systemctl suspend";               # suspend pc
        # }
      ];
    };
  };
}
