{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.honcho;
  workDir = "/var/lib/honcho";

  honchoSrc = pkgs.fetchFromGitHub {
    owner = "plastic-labs";
    repo = "honcho";
    rev = "7470866d12845ed4b56bf3449d058e65df96b1c1";
    hash = "sha256-g/uZgSqCOzNiGSAQugEkPwz2+Wt6DPBiMNCRjzmA8sc=";
  };

  dockerComposeYml = pkgs.writeText "docker-compose.yml" ''
    services:
      api:
        build:
          context: ${honchoSrc}
          dockerfile: Dockerfile
        entrypoint: ["sh", "docker/entrypoint.sh"]
        depends_on:
          database:
            condition: service_healthy
          redis:
            condition: service_healthy
        ports:
          - "127.0.0.1:8000:8000"
        env_file:
          - .env
        environment:
          - DB_CONNECTION_URI=postgresql+psycopg://honcho:honcho@database:5432/honcho
          - CACHE_URL=redis://redis:6379/0?suppress=true
          - CACHE_ENABLED=true
        restart: unless-stopped

      deriver:
        build:
          context: ${honchoSrc}
          dockerfile: Dockerfile
        entrypoint: ["/app/.venv/bin/python", "-m", "src.deriver"]
        depends_on:
          database:
            condition: service_healthy
          redis:
            condition: service_healthy
        env_file:
          - .env
        environment:
          - DB_CONNECTION_URI=postgresql+psycopg://honcho:honcho@database:5432/honcho
          - CACHE_URL=redis://redis:6379/0?suppress=true
          - CACHE_ENABLED=true
          - METRICS_ENABLED=false
        restart: unless-stopped

      database:
        image: pgvector/pgvector:pg15
        restart: unless-stopped
        command: ["postgres", "-c", "max_connections=200"]
        environment:
          - POSTGRES_DB=honcho
          - POSTGRES_USER=honcho
          - POSTGRES_PASSWORD=honcho
          - PGDATA=/var/lib/postgresql/data/pgdata
        volumes:
          - pgdata:/var/lib/postgresql/data/
        healthcheck:
          test: ["CMD-SHELL", "pg_isready -U honcho -d honcho"]
          interval: 5s
          timeout: 5s
          retries: 5

      redis:
        image: redis:8.2
        restart: unless-stopped
        volumes:
          - redis-data:/data
        healthcheck:
          test: ["CMD-SHELL", "redis-cli ping"]
          interval: 5s
          timeout: 5s
          retries: 5

    volumes:
      pgdata:
      redis-data:
  '';

  configToml = pkgs.writeText "config.toml" ''
    [app]
    LOG_LEVEL = "INFO"
    SESSION_OBSERVERS_LIMIT = 10
    GET_CONTEXT_MAX_TOKENS = 100000
    MAX_FILE_SIZE = 5242880
    MAX_MESSAGE_SIZE = 25000
    EMBED_MESSAGES = true
    MAX_EMBEDDING_TOKENS = 8192
    NAMESPACE = "honcho"

    [db]
    CONNECTION_URI = "postgresql+psycopg://honcho:honcho@database:5432/honcho"
    SCHEMA = "public"
    POOL_SIZE = 10
    MAX_OVERFLOW = 20
    POOL_TIMEOUT = 30
    POOL_RECYCLE = 300

    [auth]
    USE_AUTH = false

    [cache]
    ENABLED = true
    URL = "redis://redis:6379/0?suppress=true"
    DEFAULT_TTL_SECONDS = 300

    [llm]
    DEFAULT_MAX_TOKENS = 2500
    EMBEDDING_PROVIDER = "openrouter"
    OPENAI_COMPATIBLE_BASE_URL = "https://api.venice.ai/api/v1"

    [deriver]
    ENABLED = true
    WORKERS = 1
    POLLING_SLEEP_INTERVAL_SECONDS = 1.0
    STALE_SESSION_TIMEOUT_MINUTES = 5
    PROVIDER = "vllm"
    MODEL = "z-ai/glm-4.7-flash"
    BACKUP_PROVIDER = "custom"
    BACKUP_MODEL = "zai-org-glm-4.7-flash"
    DEDUPLICATE = true
    MAX_OUTPUT_TOKENS = 4096
    THINKING_BUDGET_TOKENS = 1
    MAX_INPUT_TOKENS = 23000
    WORKING_REPRESENTATION_MAX_OBSERVATIONS = 100
    REPRESENTATION_BATCH_MAX_TOKENS = 1024
    FLUSH_ENABLED = false

    [dialectic]
    MAX_OUTPUT_TOKENS = 8192
    MAX_INPUT_TOKENS = 100000
    HISTORY_TOKEN_LIMIT = 8192
    SESSION_HISTORY_MAX_TOKENS = 4096

    [dialectic.levels.minimal]
    PROVIDER = "vllm"
    MODEL = "z-ai/glm-4.7-flash"
    BACKUP_PROVIDER = "custom"
    BACKUP_MODEL = "zai-org-glm-4.7-flash"
    THINKING_BUDGET_TOKENS = 1
    MAX_TOOL_ITERATIONS = 1
    MAX_OUTPUT_TOKENS = 250

    [dialectic.levels.low]
    PROVIDER = "vllm"
    MODEL = "z-ai/glm-4.7-flash"
    BACKUP_PROVIDER = "custom"
    BACKUP_MODEL = "zai-org-glm-4.7-flash"
    THINKING_BUDGET_TOKENS = 1
    MAX_TOOL_ITERATIONS = 5

    [dialectic.levels.medium]
    PROVIDER = "vllm"
    MODEL = "x-ai/grok-4.1-fast"
    BACKUP_PROVIDER = "custom"
    BACKUP_MODEL = "grok-41-fast"
    THINKING_BUDGET_TOKENS = 1
    MAX_TOOL_ITERATIONS = 2

    [dialectic.levels.high]
    PROVIDER = "vllm"
    MODEL = "x-ai/grok-4.1-fast"
    BACKUP_PROVIDER = "custom"
    BACKUP_MODEL = "grok-41-fast"
    THINKING_BUDGET_TOKENS = 1
    MAX_TOOL_ITERATIONS = 4

    [dialectic.levels.max]
    PROVIDER = "vllm"
    MODEL = "z-ai/glm-5"
    BACKUP_PROVIDER = "custom"
    BACKUP_MODEL = "zai-org-glm-5"
    THINKING_BUDGET_TOKENS = 1
    MAX_TOOL_ITERATIONS = 10

    [summary]
    ENABLED = true
    MESSAGES_PER_SHORT_SUMMARY = 20
    MESSAGES_PER_LONG_SUMMARY = 60
    PROVIDER = "vllm"
    MODEL = "z-ai/glm-4.7-flash"
    BACKUP_PROVIDER = "custom"
    BACKUP_MODEL = "zai-org-glm-4.7-flash"
    MAX_TOKENS_SHORT = 1000
    MAX_TOKENS_LONG = 4000
    THINKING_BUDGET_TOKENS = 1

    [dream]
    ENABLED = true
    DOCUMENT_THRESHOLD = 50
    IDLE_TIMEOUT_MINUTES = 60
    MIN_HOURS_BETWEEN_DREAMS = 8
    ENABLED_TYPES = ["omni"]
    PROVIDER = "vllm"
    MODEL = "z-ai/glm-5"
    BACKUP_PROVIDER = "custom"
    BACKUP_MODEL = "zai-org-glm-5"
    MAX_OUTPUT_TOKENS = 16384
    THINKING_BUDGET_TOKENS = 1
    MAX_TOOL_ITERATIONS = 20
    HISTORY_TOKEN_LIMIT = 16384
    DEDUCTION_MODEL = "x-ai/grok-4.1-fast"
    INDUCTION_MODEL = "x-ai/grok-4.1-fast"

    [peer_card]
    ENABLED = true

    [vector_store]
    TYPE = "pgvector"
    DIMENSIONS = 1536

    [metrics]
    ENABLED = false

    [telemetry]
    ENABLED = false

    [sentry]
    ENABLED = false
  '';

  honchoConfigJson = pkgs.writeText "honcho-config.json" ''
    {
      "enabled": true,
      "baseUrl": "http://localhost:8000",
      "workspace": "hermes",
      "aiPeer": "hermes",
      "memoryMode": "hybrid",
      "writeFrequency": "async",
      "dialecticReasoningLevel": "low",
      "dialecticMaxChars": 600,
      "recallMode": "hybrid",
      "sessionStrategy": "per-directory",
      "hosts": {
        "hermes": {
          "enabled": true,
          "workspace": "hermes",
          "aiPeer": "hermes"
        }
      }
    }
  '';

  envFile = pkgs.writeText "honcho-env-template" ''
    LLM_VLLM_API_KEY=__OPENROUTER_KEY__
    LLM_VLLM_BASE_URL=https://openrouter.ai/api/v1
    LLM_EMBEDDING_API_KEY=__OPENROUTER_KEY__
    LLM_EMBEDDING_BASE_URL=https://openrouter.ai/api/v1
    LLM_EMBEDDING_MODEL=openai/text-embedding-3-small
    LLM_OPENAI_COMPATIBLE_API_KEY=__OPENROUTER_KEY__
    LLM_OPENAI_API_KEY=__OPENROUTER_KEY__
  '';
in {
  options.services.honcho = {
    enable = mkEnableOption "self-hosted Honcho memory service";

    openrouterApiKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        File containing the OpenRouter API key for Honcho.
        Set this to a sops-decrypted path like config.sops.secrets."openrouter-key".path
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${workDir} 0755 root root -"
      "L+ ${workDir}/docker-compose.yml - - - - ${dockerComposeYml}"
      "L+ ${workDir}/config.toml - - - - ${configToml}"
    ];

    systemd.services.honcho = {
      description = "Self-hosted Honcho memory service";
      after = [ "docker.service" "network-online.target" "sops-nix.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "sops-nix.service" "network-online.target" ];

      preStart = ''
        install -m 0600 ${envFile} ${workDir}/.env
        ${lib.optionalString (cfg.openrouterApiKeyFile != null) ''
          KEY=$(cat '${cfg.openrouterApiKeyFile}')
          sed -i "s|__OPENROUTER_KEY__|$KEY|g" ${workDir}/.env
        ''}
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = workDir;
        ExecStart = "${pkgs.docker}/bin/docker compose up -d";
        ExecStop = "${pkgs.docker}/bin/docker compose down";
        ExecReload = "${pkgs.docker}/bin/docker compose restart";
        TimeoutStartSec = 600;
        TimeoutStopSec = 120;
      };
    };

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
