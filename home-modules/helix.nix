{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      keys.normal = {
        C-right = "jump_view_right";
        C-left = "jump_view_left";
        C-up = "jump_view_up";
        C-down = "jump_view_down";
        C-y = "jump_forward";
        C-u = "jump_backward";
        C-A-v = "vsplit";
        C-A-h = "hsplit";
        C-A-c = "wclose";
        C-A-w = ":bclose";
      };
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

        end-of-line-diagnostics = "error";
        inline-diagnostics = {
          cursor-line = "warning";
        };

      };
    };
    languages = {
      language = [
        {
          name = "rust";
          language-servers = [ "rust-analyzer" "lsp-ai" ];
          # debugger = {
          #   command = "bs";
          #   name = "bugstalker";
          #   # port-arg = "-p {}";
          #   transport = "stdio";
          #   templates = [{
          #     name = "binary";
          #     request = "launch";
          #     completion = [{
          #       completion = "filename";
          #       name = "binary";
          #     }];
          #     args = {
          #       program = "{0}";
          #       # runInTerminal = true;
          #     };
          #   }];
          # };
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
      language-server.rust-analyzer.config = {
        check.command = "clippy";
      };
      language-server.lsp-ai = {
        command = "${pkgs.lsp-ai}/bin/lsp-ai";
        config = {
          chat = [{
            trigger = "";
            action_display_name = "Chat";
            model = "model3";
            parameters = {
              max_content = 4096;
              max_tokens = 1024;
              n_cx_per_seq = 131072;
              messages = [
                { role = "system"; content = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do you best to answer succinctly and accurately"; }
              ];
            };
          }
          {
            trigger = "";
            action_display_name = "Chat with context";
            model = "model1";
            parameters = {
              max_context = 4096;
              max_tokens = 4096;
              # n_ctx_per_seq = 131072;
              system = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do you best to answer succinctly and accurately given the code context:\n\n{CONTEXT}";
              # messages = [
              #   { role = "user"; content = "{CODE}"; }
              # ];
            };
          }
          ];
          actions = [
            {
              action_display_name = "Complete";
              model = "model1";
              parameters = {
                max_context = 4096;
                max_tokens = 4096;
                system = "You are an AI coding assistant. Your task is to complete code snippets. The user's cursor position is marked by \"<CURSOR>\". Follow these steps:\n\n1. Analyze the code context and the cursor position.\n2. Provide your chain of thought reasoning, wrapped in <reasoning> tags. Include thoughts about the cursor position, what needs to be completed, and any necessary formatting.\n3. Determine the appropriate code to complete the current thought, including finishing partial words or lines.\n4. Replace \"<CURSOR>\" with the necessary code, ensuring proper formatting and line breaks.\n5. Wrap your code solution in <answer> tags.\n\nYour response should always include both the reasoning and the answer. Pay special attention to completing partial words or lines before adding new lines of code.\n\n<examples>\n<example>\nUser input:\n--main.py--\n# A function that reads in user inpu<CURSOR>\n\nResponse:\n<reasoning>\n1. The cursor is positioned after \"inpu\" in a comment describing a function that reads user input.\n2. We need to complete the word \"input\" in the comment first.\n3. After completing the comment, we should add a new line before defining the function.\n4. The function should use Python's built-in `input()` function to read user input.\n5. We'll name the function descriptively and include a return statement.\n</reasoning>\n\n<answer>t\ndef read_user_input():\n    user_input = input(\"Enter your input: \")\n    return user_input\n</answer>\n</example>\n\n<example>\nUser input:\n--main.py--\ndef fibonacci(n):\n    if n <= 1:\n        return n\n    else:\n        re<CURSOR>\n\n\nResponse:\n<reasoning>\n1. The cursor is positioned after \"re\" in the 'else' clause of a recursive Fibonacci function.\n2. We need to complete the return statement for the recursive case.\n3. The \"re\" already present likely stands for \"return\", so we'll continue from there.\n4. The Fibonacci sequence is the sum of the two preceding numbers.\n5. We should return the sum of fibonacci(n-1) and fibonacci(n-2).\n</reasoning>\n\n<answer>turn fibonacci(n-1) + fibonacci(n-2)</answer>\n</example>\n</examples>";
                messages = [
                  {
                    role = "user";
                    content = "{CODE}";
                  }
                ];
              };
              post_process = {
                extractor = "(?s)<answer>(.*?)</answer>";
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
    ignores = [
      "!.gitignore"
      ".build/"
      "target/"
      "flake.lock"
    ];
  };

  home = {
    packages = with pkgs; [
        # LSPs
        nil
        lsp-ai
       
        rust-analyzer
        markdown-oxide
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
        kdlfmt

        # Debuggers
        bugstalker # Rust debugger

        # Preview
        gh-markdown-preview
    ];
  };
}
