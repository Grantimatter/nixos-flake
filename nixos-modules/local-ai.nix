{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.local-ai;
  modelsDir = "/mnt/sdb2/ai/models";
in {
  options.local-ai = {
    enable = mkEnableOption "Local AI inference via Ollama";
    exposeLan = mkOption {
      type = types.bool;
      default = false;
      description = "Expose Ollama API on 0.0.0.0 for LAN access";
    };
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      acceleration = "cuda";
      models = modelsDir;
      host = if cfg.exposeLan then "0.0.0.0" else "127.0.0.1";
      environmentVariables = {
        OLLAMA_KEEP_ALIVE = "5m";
        OLLAMA_MAX_LOADED_MODELS = "1";
        OLLAMA_NUM_PARALLEL = "1";
      };
    };

    environment.systemPackages = with pkgs; [
      ollama
    ];

    networking.firewall = mkIf cfg.exposeLan {
      allowedTCPPorts = [ 11434 ];
    };
  };
}
