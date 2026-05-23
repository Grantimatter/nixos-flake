{ lib, config, pkgs, ... }:

let
  ewwPkg = config.programs.eww.package;

  ewwScripts = pkgs.symlinkJoin {
    name = "eww-scripts";
    paths = with pkgs; [
      (writeShellScriptBin "eww-workspaces" ''
        active=$(hyprctl activeworkspace -j | ${jq}/bin/jq '.id')
        hyprctl workspaces -j | ${jq}/bin/jq "map({id: .id, name: .name, windows: .windows, active: (.id == $active)})"
      '')
      (writeShellScriptBin "eww-audio" ''
        default_sink=$(${pulseaudio}/bin/pactl info 2>/dev/null | ${gnugrep}/bin/grep "Default Sink" | cut -d: -f2 | xargs)
        sink_name=$(${pulseaudio}/bin/pactl list sinks 2>/dev/null | ${gnugrep}/bin/grep -A10 "Name: $default_sink" | ${gnugrep}/bin/grep "Description:" | head -1 | cut -d: -f2 | xargs)
        volume_output=$(${pulseaudio}/bin/pactl get-sink-volume "$default_sink" 2>/dev/null)
        volume=$(echo "$volume_output" | ${gnugrep}/bin/grep "front-left:" | awk '{print $5}' | tr -d '%')
        muted=$(${pulseaudio}/bin/pactl get-sink-mute "$default_sink" 2>/dev/null | ${gnugrep}/bin/grep -q "yes" && echo "true" || echo "false")
        sinks=$(${pulseaudio}/bin/pactl list sinks 2>/dev/null | ${gnugrep}/bin/grep -B20 "^Name:" | ${gnugrep}/bin/grep -E "^(Name:|Description:)" | paste - - | sed 's/Name: //;s/Description: //' | while read name desc; do echo "$name|$desc"; done | ${jq}/bin/jq -R -s 'split("\n") | map(select(length > 0) | split("|") | {name: .[0], description: .[1]})')
        ${jq}/bin/jq -nc \
          --arg default_sink "$default_sink" \
          --arg sink_name "$sink_name" \
          --argjson volume "''${volume:-0}" \
          --argjson muted "$muted" \
          --argjson sinks "$sinks" \
          '{default_sink: $default_sink, sink_name: $sink_name, volume: $volume, muted: $muted, sinks: $sinks}'
      '')
      (writeShellScriptBin "eww-audio-up" ''
        ${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%
      '')
      (writeShellScriptBin "eww-audio-down" ''
        ${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%
      '')
      (writeShellScriptBin "eww-audio-mute" ''
        ${pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
      '')
      (writeShellScriptBin "eww-audio-set-sink" ''
        ${pulseaudio}/bin/pactl set-default-sink "$1"
      '')
      (writeShellScriptBin "eww-wifi" ''
        ssid=$(${networkmanager}/bin/nmcli -t -f active,ssid device wifi list 2>/dev/null | ${gnugrep}/bin/grep "^yes" | cut -d: -f2)
        signal=$(${networkmanager}/bin/nmcli -t -f active,signal device wifi list 2>/dev/null | ${gnugrep}/bin/grep "^yes" | cut -d: -f2)
        connected=false
        [ -n "$ssid" ] && connected=true
        networks=$(${networkmanager}/bin/nmcli -t -f ssid,signal,bars,security device wifi list 2>/dev/null | head -10 | ${jq}/bin/jq -R -s 'split("\n") | map(select(length > 0) | split(":") | {ssid: .[0], signal: (.[1]|tonumber), bars: .[2], security: .[3]})')
        ${jq}/bin/jq -nc \
          --arg ssid "''${ssid:-}" \
          --argjson signal "''${signal:-0}" \
          --argjson connected "$connected" \
          --argjson networks "$networks" \
          '{ssid: $ssid, signal: $signal, connected: $connected, networks: $networks}'
      '')
      (writeShellScriptBin "eww-system" ''
        cpu=$(awk '/^cpu / {total=$2+$3+$4+$5+$6+$7+$8; idle=$5; printf "%.0f", (total-idle)/total*100}' /proc/stat)
        mem=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf "%.0f", (t-a)/t*100}' /proc/meminfo)
        disk=$(df -h / 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print $5}')
        secs=$(awk '{print int($1)}' /proc/uptime)
        days=$((secs / 86400))
        hours=$(( (secs % 86400) / 3600 ))
        mins=$(( (secs % 3600) / 60 ))
        uptime=""
        [ "$days" -gt 0 ] && uptime="''${days}d"
        [ "$hours" -gt 0 ] && uptime="''${uptime} ''${hours}h"
        uptime="''${uptime} ''${mins}m"
        ${jq}/bin/jq -nc \
          --argjson cpu "$cpu" \
          --argjson mem "$mem" \
          --argjson disk "''${disk:-0}" \
          --arg uptime "$uptime" \
          '{cpu: $cpu, memory: $mem, disk: $disk, uptime: $uptime}'
      '')
      (writeShellScriptBin "eww-wifi-disconnect" ''
        iface=$(${networkmanager}/bin/nmcli -t -f type,device device status 2>/dev/null | ${gnugrep}/bin/grep "^wifi" | cut -d: -f2)
        [ -n "$iface" ] && ${networkmanager}/bin/nmcli device disconnect "$iface"
      '')
    ];
  };
in {
  home.packages = with pkgs; [ ewwScripts jq ];

  programs.eww = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  xdg.configFile."eww".source = ./config;
  xdg.configFile."eww".recursive = true;

  wayland.windowManager.hyprland.settings = {
    exec-once = lib.mkAfter [
      "${ewwPkg}/bin/eww daemon"
    ];

    bind = lib.mkAfter [
      "$mod, SPACE, exec, ${pkgs.writeShellScriptBin "eww-dock-toggle" ''
        if ! ${ewwPkg}/bin/eww active-windows 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q "dock"; then
          ${ewwPkg}/bin/eww open dock 2>/dev/null
        else
          ${ewwPkg}/bin/eww close dock 2>/dev/null
        fi
      ''}/bin/eww-dock-toggle"
    ];
  };
}
