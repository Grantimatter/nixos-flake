{ config, lib, pkgs, inputs, ... }:

with lib;

let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };

  cfg = config.monitoring;

  textfileDir = "/var/lib/node_exporter/textfile";

  nvidiaGpuExporter = pkgs.writeShellScriptBin "nvidia-gpu-exporter" ''
    set -o errexit
    export PATH="/run/current-system/sw/bin:$PATH"
    OUTPUT="${textfileDir}/nvidia.prom"
    TMPFILE="''$(mktemp)"
    trap 'rm -f "$TMPFILE"' EXIT

    nvidia-smi --query-gpu=index,name,utilization.gpu,utilization.memory,memory.used,memory.total,temperature.gpu,fan.speed,power.draw,power.limit --format=csv,noheader,nounits 2>/dev/null | while IFS=, read -r idx name util_gpu util_mem mem_used mem_total temp fan power power_limit; do
      idx="''$(echo "$idx" | xargs)"
      name="''$(echo "$name" | xargs)"
      util_gpu="''$(echo "$util_gpu" | xargs)"
      util_mem="''$(echo "$util_mem" | xargs)"
      mem_used="''$(echo "$mem_used" | xargs)"
      mem_total="''$(echo "$mem_total" | xargs)"
      temp="''$(echo "$temp" | xargs)"
      fan="''$(echo "$fan" | xargs)"
      power="''$(echo "$power" | xargs)"
      power_limit="''$(echo "$power_limit" | xargs)"

      mem_used_bytes=$((mem_used * 1048576))
      mem_total_bytes=$((mem_total * 1048576))
      cat >> "$TMPFILE" << EOF
    nvidia_gpu_utilization{gpu="$idx",gpu_name="$name"} $util_gpu
    nvidia_memory_utilization{gpu="$idx",gpu_name="$name"} $util_mem
    nvidia_memory_used_bytes{gpu="$idx",gpu_name="$name"} $mem_used_bytes
    nvidia_memory_total_bytes{gpu="$idx",gpu_name="$name"} $mem_total_bytes
    nvidia_temperature_celsius{gpu="$idx",gpu_name="$name"} $temp
    nvidia_fan_speed_percent{gpu="$idx",gpu_name="$name"} $fan
    nvidia_power_draw_watts{gpu="$idx",gpu_name="$name"} $power
    nvidia_power_limit_watts{gpu="$idx",gpu_name="$name"} $power_limit
    EOF
    done

    nvidia-smi pmon -c 1 -s u 2>/dev/null | tail -n +3 | while read -r gpu pid type sm mem enc dec jpg ofa command; do
      gpu="''$(echo "$gpu" | xargs)"
      pid="''$(echo "$pid" | xargs)"
      type="''$(echo "$type" | xargs)"
      sm="''$(echo "$sm" | xargs)"
      mem="''$(echo "$mem" | xargs)"
      command="''$(echo "$command" | xargs | sed 's/[()]//g')"

      if [ "$pid" != "-" ] && [ -n "$pid" ]; then
        [ "$sm" = "-" ] && sm="0"
        [ "$mem" = "-" ] && mem="0"
        cat >> "$TMPFILE" << EOF
    nvidia_process_sm_utilization_percent{gpu="$gpu",pid="$pid",process="$command"} $sm
    nvidia_process_mem_utilization_percent{gpu="$gpu",pid="$pid",process="$command"} $mem
    EOF
      fi
    done

    nvidia-smi --query-compute-apps=pid,process_name,used_gpu_memory,gpu_bus_id --format=csv,noheader 2>/dev/null | while IFS=, read -r pid proc_name used_mem bus_id; do
      pid="''$(echo "$pid" | xargs)"
      proc_name="''$(echo "$proc_name" | xargs)"
      used_mem="''$(echo "$used_mem" | xargs | sed 's/ MiB//')"
      bus_id="''$(echo "$bus_id" | xargs)"

      if [ -n "$pid" ] && [ "$pid" != "0" ]; then
        used_mem_bytes=$((used_mem * 1048576))
        cat >> "$TMPFILE" << EOF
    nvidia_process_memory_used_bytes{pid="$pid",process="$proc_name",gpu_bus_id="$bus_id"} $used_mem_bytes
    EOF
      fi
    done

    if [ -s "$TMPFILE" ]; then
      mv "$TMPFILE" "$OUTPUT"
      chmod 644 "$OUTPUT"
    fi
  '';

  grafana-assistant-app = pkgs.stdenvNoCC.mkDerivation {
    pname = "grafana-assistant-app";
    version = "2.0.15";
    src = pkgs.fetchurl {
      name = "grafana-assistant-app-2.0.15.zip";
      url = "https://grafana.com/api/plugins/grafana-assistant-app/versions/2.0.15/download";
      hash = "sha256-U3LIuAByJ86ZjpojYsCtwodU6nxaCahNtqRRR5F8dIQ=";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    installPhase = ''
      mkdir -p /tmp/extracted
      unzip -d /tmp/extracted "$src"
      cd /tmp/extracted/*
      cp -R . "$out"
      rm -rf /tmp/extracted
      chmod -R a-w "$out"
      chmod u+w "$out"
    '';
  };

  alloyConfig = pkgs.writeText "alloy-config.alloy" ''
    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
      rule {
        source_labels = ["__journal_syslog_identifier"]
        target_label  = "identifier"
      }
    }

    loki.source.journal "default" {
      max_age = "12h"
      labels = {
        job = "systemd-journal",
      }
      relabel_rules = loki.relabel.journal.rules
      forward_to = [loki.write.local.receiver]
    }

    loki.write "local" {
      endpoint {
        url = "http://localhost:3100/loki/api/v1/push"
      }
    }

    pyroscope.ebpf "default" {
      forward_to = [pyroscope.write.local.receiver]
    }

    pyroscope.write "local" {
      endpoint {
        url = "http://localhost:4040"
      }
    }
  '';
in
{
  disabledModules = [
    "services/monitoring/grafana.nix"
    "services/monitoring/loki.nix"
    "services/monitoring/alloy.nix"
    "services/monitoring/prometheus/default.nix"
    "services/monitoring/pyroscope.nix"
  ];

  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/monitoring/grafana.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/monitoring/loki.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/monitoring/alloy.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/monitoring/prometheus"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/monitoring/pyroscope.nix"
  ];

  options.monitoring = {
    enable = mkEnableOption "Grafana + Prometheus + Loki monitoring stack";
    nvidiaGpu = mkEnableOption "NVIDIA GPU metrics via nvidia-smi";
  };

  config = mkMerge [
    (mkIf cfg.enable {

      nixpkgs.overlays = [
        (final: prev: {
          inherit (pkgs-unstable) grafana grafana-loki grafana-alloy prometheus grafanaPlugins pyroscope;
        })
      ];

      services.prometheus = {
        enable = true;
        port = 9001;
        listenAddress = "127.0.0.1";
        retentionTime = "30d";
        exporters.node = {
          enable = true;
          enabledCollectors = [ "systemd" "processes" "zfs" ];
          port = 9100;
          listenAddress = "127.0.0.1";
        };
        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [{ targets = [ "127.0.0.1:9100" ]; }];
          }
          {
            job_name = "pushgateway";
            honor_labels = true;
            static_configs = [{ targets = [ "127.0.0.1:9091" ]; }];
          }
        ];
      };

      services.loki = {
        enable = true;
        configFile = pkgs.writeText "loki-config.yaml" ''
          auth_enabled: false
          server:
            http_listen_address: 127.0.0.1
            http_listen_port: 3100
            grpc_listen_port: 0
          common:
            ring:
              kvstore:
                store: inmemory
            replication_factor: 1
            path_prefix: /var/lib/loki
          schema_config:
            configs:
              - from: 2024-01-01
                store: tsdb
                object_store: filesystem
                schema: v13
                index:
                  prefix: index_
                  period: 24h
          storage_config:
            tsdb_shipper:
              active_index_directory: /var/lib/loki/index
              cache_location: /var/lib/loki/index_cache
            filesystem:
              directory: /var/lib/loki/chunks
          compactor:
            working_directory: /var/lib/loki/compactor
          limits_config:
            reject_old_samples: true
            reject_old_samples_max_age: 168h
          table_manager:
            retention_deletes_enabled: true
            retention_period: 336h
        '';
      };

      services.pyroscope = {
        enable = true;
        settings = {
          server = {
            http_listen_address = "127.0.0.1";
            http_listen_port = 4040;
            grpc_listen_address = "127.0.0.1";
            grpc_listen_port = 9095;
          };
          memberlist.bind_addr = [ "127.0.0.1" ];
        };
        extraFlags = [
          "-memberlist.advertise-addr=127.0.0.1"
          "-ingester.lifecycler.addr=127.0.0.1"
          "-distributor.ring.instance-addr=127.0.0.1"
          "-compactor.ring.instance-addr=127.0.0.1"
          "-overrides-exporter.ring.instance-addr=127.0.0.1"
          "-query-scheduler.ring.instance-addr=127.0.0.1"
          "-store-gateway.sharding-ring.instance-addr=127.0.0.1"
          "-query-frontend.instance-addr=127.0.0.1"
        ];
      };

      services.alloy = {
        enable = true;
        configPath = alloyConfig;
      };

      systemd.services.alloy.serviceConfig.AmbientCapabilities = [ "CAP_BPF" "CAP_PERFMON" ];

      networking.hosts."127.0.0.1" = [ "grafana.nixos-desktop.local" ];

      services.caddy = {
        enable = true;
        virtualHosts."grafana.nixos-desktop.local" = {
          extraConfig = ''
            tls internal
            reverse_proxy localhost:3000
          '';
        };
      };

      services.grafana = {
        enable = true;
        declarativePlugins = with pkgs.grafanaPlugins; [
          grafana-lokiexplore-app
          grafana-metricsdrilldown-app
          grafana-pyroscope-app
          frser-sqlite-datasource
        ] ++ [ grafana-assistant-app ];
        settings = {
          security.secret_key = "$__file{/var/lib/grafana/secret_key}";
          server = {
            http_addr = "127.0.0.1";
            http_port = 3000;
            domain = "grafana.nixos-desktop.local";
            root_url = "https://grafana.nixos-desktop.local";
          };
          analytics.check_for_plugin_updates = false;
          feature_toggles.disable = ["dashboardScene"];
        };
        provision = {
          enable = true;
          datasources.settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:9001";
              isDefault = true;
            }
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://127.0.0.1:3100";
            }
            {
              name = "Pyroscope";
              type = "grafana-pyroscope-datasource";
              access = "proxy";
              url = "http://127.0.0.1:4040";
            }
            {
              name = "Finance SQLite";
              type = "frser-sqlite-datasource";
              access = "proxy";
              jsonData = {
                path = "/var/lib/grafana/finance.db";
              };
            }
          ];
          dashboards.settings.providers = [
            {
              name = "Finance Dashboard";
              orgId = 1;
              folder = "Finance";
              type = "file";
              options.path = "/var/lib/grafana/dashboards/finance";
              updateIntervalSeconds = 60;
            }
          ];
        };
      };

      networking.firewall.allowedTCPPorts = [ 80 443 ];

      systemd.tmpfiles.rules = [
        "d /var/lib/loki 0750 loki loki -"
        "d /var/lib/finance 0750 grafana grafana -"
      ];

      systemd.services.finance-dashboards-sync = {
        description = "Sync finance dashboard JSONs to Grafana provisioning dir";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        script = ''
          mkdir -p /var/lib/grafana/dashboards/finance
          cp -r /home/grant/dev/finance_dashboard/grafana/dashboards/*.json /var/lib/grafana/dashboards/finance/
          chown -R grafana:grafana /var/lib/grafana/dashboards/finance
        '';
      };

      systemd.services.grafana.serviceConfig.BindReadOnlyPaths = [
        "/home/grant/dev/finance_dashboard/data/finance.db:/var/lib/grafana/finance.db"
      ];

      systemd.services.finance-dashboards-sync = {
        before = [ "grafana.service" ];
        requiredBy = [ "grafana.service" ];
      };
    })

    (mkIf (cfg.enable && cfg.nvidiaGpu) {
      services.prometheus.exporters.node.extraFlags = [ "--collector.textfile.directory=${textfileDir}" ];

        systemd.services.nvidia-gpu-exporter = {
          description = "NVIDIA GPU Prometheus metrics exporter";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${nvidiaGpuExporter}/bin/nvidia-gpu-exporter";
            User = "root";
            Type = "oneshot";
          };
        };

      systemd.timers.nvidia-gpu-exporter = {
        description = "Timer for NVIDIA GPU metrics exporter";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "minutely";
          Persistent = true;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${textfileDir} 0755 - - -"
      ];
    })
  ];
}
