{ lib, pkgs, config, ... }:
{
  project.name = "homelab";

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
	ports = [ "80:80" "8080:8080" ];
	volumes = ["/var/run/docker/sock:/var/run/dockes.sock:ro"];
	networks = [ "reverse-proxy" ];
      };
    };

    portainer = {
      service = {
        image = "portainer/portainer-ce:latest";
        container_name = "portainer";
	stop_signal = "SIGINT";
	ports = [ "9000:8080" ];
	networks = [ "reverse-proxy" ];
	volumes = [
	  "/var/run/docker.sock:/var/run/docker.sock:ro"
	  "./portainer"
	];
      };
    };
  };
}
