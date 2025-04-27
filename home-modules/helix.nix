{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) optionals attrValues;
  inherit (config.home) homeDirectory;
in
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
     theme = "catppuccin_mocha"; 
      editor = {
        line-number = "relative";
        scrolloff = 15;

        lsp.display-messages = true;
        completion-timeout = 100;
        completion-trigger-len = 1;

        color-modes = true;
        popup-border = "all";
        clipboard-provider = "wayland";
        indent-guides.render = true;
        indent-guides.skip-levels = 2;

        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "warning";
        };
      };
    };
    languages = {
      language = [
        # {
        #   name = "ai-complete";
        #   file-types = [ "md" "rs" "toml" "nix" ];
        #   language-servers = [ "lsp-ai" ];
        # }
        {
          name = "rust";
          language-servers = [ "rust-analyzer" "lsp-ai" ];
        }
        {
          name = "nix";
          language-servers = [ "nil" "nixd" "lsp-ai" ];
        }
        {
          name = "markdown";
          language-servers = [ "marskman" "markdown-oxide" "lsp-ai" ];
        }
      ];
      language-server.lsp-ai = {
        command = "${pkgs.lsp-ai}/bin/lsp-ai";
        config = {
          chat = [{
            trigger = "!C";
            action_display_name = "Chat";
            model = "model3";
            parameters = {
              max_content = 4096;
              max_tokens = 1024;
              messages = [
                { role = "user"; content = "{CODE}"; }
              ];
              post_process = {
                extractor = "(?s)<answer>(.*?)</answer>";
              };
            };
          }
          {
            trigger = "!CC";
            action_display_name = "Chat with context";
            model = "model1";
            parameters = {
              max_context = 4096;
              max_tokens = 4096;
              system = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do your best to answer succinctly and accurately";
              messages = [
                { role = "user"; content = "{CODE}"; }
              ];
              post_process = {
                extractor = "(?s)<answer>(.*?)</answer>";
              };
            };
          }
          ];
          memory = {
           file_store = { };
          };
          models.model1 = {
            type = "ollama";
            model = "qwen2.5-coder:latest";
            chat_endpoint="http://localhost:7869/api/chat";
            generate_endpoint="http://localhost:7869/api/generate";
          };
          models.model2 = {
            type = "open_ai";
            model = "llama-3.1-8b-instant";
            chat_endpoint = "https://api.groq.com/openai/v1/chat/completions";
            auth_token_env_var_name = "OPEN_API_KEY";
          };
          models.model3 = {
            type = "ollama";
            model = "deepseek-r1";
            chat_endpoint="http://localhost:7869/api/chat";
            generate_endpoint="http://localhost:7869/api/generate";
          };
        };
      };
    };
  };

  home = {
    packages = (attrValues) {
      inherit (pkgs)
        # LSPs
        nil
        lsp-ai
        
        # rust-analyzer
        marksman
        lua-language-server
        typescript-language-server
        vscode-langservers-extracted
        zls
        bash-language-server
        dockerfile-language-server-nodejs
        docker-compose-language-service
        gopls
        haskell-language-server
        jdt-language-server

        # Linters
        clippy
        shellcheck

        # Formatters
        nixpkgs-fmt
        ;
    };
  };
}
