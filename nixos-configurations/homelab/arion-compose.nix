{ pkgs, config, ... }:
let
  server = {
    dir = "/etc/homelab";
    config = "/etc/homelab/config";
    data = "/etc/homelab/data";
    backup = "/etc/homelab/backup";
  };
  
#  traefik_service_labels = {
#    "";
#  };

  volume_docker_sock = "/var/run/docker.sock:/var/run/docker:ro";
in
{
  imports = [
#    inputs.sops-nix.nixosModules.default
  ];
  config.project.name = "homelab";

  config.docker-compose.volumes = {
    nas-safe = {
      
    };

    nas-mass = {
      name = "nas-mass";
      driver_opts = {
        type = "cifs";
	o = "";
	device = "";
      };
    };
  };

  config.networks = {
    reverse-proxy = {
      name = "reverse-proxy";
      ipam = {
	config = [{
	  subnet = "172.32.0.0/16";
	  gateway = "172.32.0.1";
	}];
      };
    };
  };

  config.services = {
    traefik = {
      service = {
        image = "traefik";
	container_name = "traefik";
	stop_signal = "SIGINT";
	ports = [ "80:80" "443:443" "2456:2456/udp" ];
	volumes = [ "${volume_docker_sock}" ];
	networks = [ "reverse-proxy" ];
	environment = {
	  CF_API_EMAIL = "";
	  CF_DNS_TOKEN = "";
	};
	labels = {
	  "traefik.enable" = "true";
	};
      };
    };

    portainer = {
      service = {
        image = "portainer/portainer-ce:latest";
        container_name = "portainer";
	stop_signal = "SIGINT";
	ports = [ "9000:9000" ];
	networks = [ "reverse-proxy" ];
	volumes = [
	  "${volume_docker_sock}"
	  "${server.data}/portainer:/data"
	];
      };
    };

    paperless = {
      service = {
	image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
	container_name = "paperless";
	ports = [ "8000:8000" ];
	networks = [ "reverse-proxy" ];
	volumes = [ "${server.data}/paperles-ngx:/usr/src/paperless/consume" ];
      };
    };

    duplicati = {
      service = {
	image = "lscr.io/linuxserver/duplicati:latest";
	container_name = "duplicati";
	ports = [ "8200:8200" ];
	networks = [ "reverse-proxy" ];
	volumes = [
	  "${server.config}/duplicati:/config"
	  "${server.config}:/source/config"
	  "${server.data}:/source/data"
	  "${server.backup}:/backup"
	];
      };
    };

    restic = {
      service = {
	image = "restic/restic";
	container_name = "restic";
	volumes = [
	  "${server.config}/restic:/config"
	  "${server.config}:/source/config"
	  "${server.data}:/source/data"
	  "${server.backup}:/backup"
	];
      };
    };

    transmission-openvpn = {
    service = {
      image = "haugene/transmission-openvpn";
      container_name = "transmission";
      capabilities = {
	NET_ADMIN = true;
      };
#      "logging" = {
#        driver = "json-file";
#        options.max-size = "10m";
#      };
      ports = [ "9091:9091" ];
      networks = [ "reverse-proxy" ];
      volumes = [
	"${server.config}/transmission:/config"
	"${server.data}/transmission:/data"
      ];
      environment = {
	OPENVPN_PROVIDER = "PIA";
	OPENVPN_CONFIG = "";
	OPENVPN_USERNAME = "";
	OPENVPN_PASSWORD = "";
	LOCAL_NETWORK = "192.168.50.0/16";
      };
    };
    };

  };
}
