{
  config,
  pkgs,
  ...
}:
{
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    extraDependencyGroups = [ "honcho" "messaging" "voice" ];
    environmentFiles = [ config.sops.secrets."hermes-env".path ];
    restart = "always";
    settings = {
      toolsets = [
        "web_search"
        "web_extract"
        "tts"
        "terminal"
      ];
      web = {
        search_backend = "searxng";
        extract_backend = "firecrawl";
      };
      tts = {
        provider = "edge";
        speed = "1.0";
        edge.voice = "en-US-AndrewMultilingualNeural";
        edge.speed = 1.0;
      };
      stt = {
        provider = "local";
        local.model = "distil-large-v3";
      };
      memory.provider = "honcho";
      model = {
        base_url = "https://opencode.ai/zen/v1";
        default = "deepseek-v4-flash-free";
        provider = "opencode-zen";
      };
      terminal.cwd = "/var/lib/hermes/workspace";
      telegram = {
        require_mention = true;
        observe_unmentioned_group_messages = true;
      };
    };
  };

  services.searx = {
    enable = true;
    environmentFile = config.sops.secrets."searx-env".path;
  };

  # services.wyoming.faster-whisper."base" = {
  #   enable = true;
  #   language = "en";
  #   uri = "tcp://0.0.0.0:10300";
  #   device = "cuda";
  #   model = "distil-large-v3";
  # };

  system.activationScripts."hermes-honcho-config" = {
    deps = [ "users" "hermes-agent-setup" "setupSecrets" ];
    text = ''
      # restore group permissions if the container entrypoint stripped them
      chmod 2770 /var/lib/hermes/.hermes
      chmod 0640 /var/lib/hermes/.hermes/.env

      install -o hermes -g hermes -m 0640 ${pkgs.writeText "hermes-honcho.json" ''
        {
          "baseUrl": "http://localhost:8000",
          "hosts": {
            "hermes": {
              "enabled": true,
              "aiPeer": "hermes",
              "workspace": "hermes",
              "recallMode": "hybrid",
              "sessionStrategy": "per-directory"
            }
          }
        }
      ''} /var/lib/hermes/.hermes/honcho.json

      # inject API keys from sops into hermes .env
      # OpenRouter (shared with honcho service)
      if [ -f /run/secrets/openrouter-key ]; then
        echo "OPENROUTER_API_KEY=$(cat /run/secrets/openrouter-key)" >> /var/lib/hermes/.hermes/.env
      fi

      # OpenCode Zen
      if [ -f /run/secrets/opencode-zen-key ]; then
        echo "OPENCODE_ZEN_API_KEY=$(cat /run/secrets/opencode-zen-key)" >> /var/lib/hermes/.hermes/.env
      fi
    '';
  };
}
