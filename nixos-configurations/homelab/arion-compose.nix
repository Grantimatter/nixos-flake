{ config, lib, ... }:
let
  server = rec {
    dir = config.xdg.configHome + "/homelab";
    config = dir + "/config";
    data   = dir + "/data";
    backup = dir + "/backup";
    cache  = dir + "/cache";
  };
  
#  traefik_service_labels = rec {
#    "";
#  };

  volume_docker_sock = "/var/run/docker.sock:/var/run/docker:ro";
in
{
  imports = [
    #inputs.sops-nix.nixosModules.default
    #(modulesPath + "/installer/scan/not-detected.nix")
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

    backrest = {
      service = {
        image = "garethgeorge/backrest";
	container_name = "backrest";
	ports = [ "9898:9898" ];
	networks = [ "reverse-proxy" ];
	volumes = [
	  "${server.config}/backrest:/config"
	  "${server.data}/backrest:/data"
	  "${server.cache}/backrest:/cache"
	  "${server.data}:/userdata"
	];
	environment = {
	  BACKREST_CONFIG = "/config/config.json";
	  BACKREST_DATA = "/data";
	  XDG_CACHE_HOME = "/cache";
	};
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

    watcharr.service = {
      image = "ghcr.io/sbondco/watcharr:latest";
      container_name = "watcharr";
      ports = [ "3080:3080" ];
      volumes = [
        "${server.data}/watcharr:/data"
      ];    
    };

    wizarr.service = {
      image = "ghcr.io/wizarrrr/wizarr:latest";
      container_name = "wizarr";
      ports = [ "5690:5690" ];
      volumes = [ "${server.data}/wizarr:/data/database" ];
    };

  };
}
