{ pkgs, ... }:
let
  server = {
    dir = "/home/homelab/server";
    config = "/home/homelab/server/config";
    data = "/home/homelab/server/data";
    backups = "/home/homelab/server/backups";
  };
  
  network_proxy = "reverse-proxy";
  traefik_service_labels = {
    ""
  };

  volume_docker_sock = "/var/run/docker/sock:/var/run/docker:/var/run/docker.sock:ro";
  dns_email = "wiswellgrant@gmail.com";
  dns_token = "SECRETHERE";
  
in
{
  config.project.name = "homelab";

  config.networks = {
    reverse-proxy = {
      name = "${network_proxy}";
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
	networks = [ "${network_proxy}" ];
	environment = {
	  CF_API_EMAIL = "${dns_email}";
	  CF_DNS_TOKEN = "${dns_token}";
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
	networks = [ "${network_proxy}" ];
	volumes = [
	  "${volume_docker_sock}"
	  "${server_data}/portainer:/data"
	];
      };
    };

    paperless = {
      service = {
	image = "paperless-ngx/paperless-ngx";
	container_name = "paperless";
	ports = [ "8000:8000" ];
	networks = [ "${network_proxy}" ];
	volumes = [ "${server_dir}/paperles-ngx:/usr/src/paperless/consume" ];
      };
    };

    duplicati = {
      service = {
	image = "lscr.io/linuxserver/duplicati:latest";
	container_name = "duplicati";
	ports = [ "8200:8200" ];
	networks = [ "${network_proxy}" ];
	volumes = [
	  "${server.config}/duplicati:/config"
	  "${server.config}:/source/config"
	  "${server.data}:/source/data"
	  "${server.backups}:/backups"
	];
      };
    };

  };
}
