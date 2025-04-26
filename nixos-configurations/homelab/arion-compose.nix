{config, lib, ...}:
let
  server = rec {
    dir = config.xdg.configHome + "/homelab";
    config = dir + "/config";
    data = dir + "/data";
    backup = dir + "/backup";
    cache = dir + "/cache";
  };
  volume_docker_sock = "/var/run/docker.sock:/var/run/docker:ro";
in
{
  imports = [
    
  ];
}
