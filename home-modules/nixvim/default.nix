{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim 
  ];
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    colorschemes.onedark.enable = true;
    viAlias = true;
    vimAlias = true;

    options = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };

    plugins = {

      telescope.enable = true;
      treesitter.enable = true;
      luasnip.enable = true;

      nvim-cmp = {
        enable = true;
        autoEnableSources = true;
        sources = [
	  {name = "nvim-lsp";}
	  {name = "path";}
	  {name = "luasnip";}
        ];
      };

      lsp = {
        enable = true;
	servers = {

	  ## Scripting ##

	  # Bash
	  bashls.enable = true;

	  # Nix
	  nil_ls.enable = true;

	  # Lua
	  lua-ls.enable = true;

	  # Python
	  pylsp.enable = true;

	  ## Compiled ##
	  
	  # cmake
	  cmake.enable = true;

	  # C / C++
	  ccls.enable = true;
	  
	  # C#
	  csharp-ls.enable = true;

          # Rust
          rust-analyzer.enable = true;
	  rust-analyzer.installCargo = false;
	  rust-analyzer.installRustc = false;

	  # Zig
	  zls.enable = true;

	  # Go
	  gopls.enable = true;

	  # Java
	  java-language-server.enable = true;

	  # Kotlin
	  kotlin-language-server.enable = true;


	  ## Functional ##
	  
	  # Haskell
	  hls.enable = true;

	  ## Web ##
          
	  # HTML
	  html.enable = true;

	  # Javascript / Typescript
          tsserver.enable = true;
	  
	  # CSS 
	  cssls.enable = true;

	  # Svelte
	  svelte.enable = true;

	  # Tailwind CSS
	  tailwindcss.enable = true;

	  ## General ##
	  efm.enable = true;


	  ## Object Notation ##
	  
	  # JSON
	  jsonls.enable = true;

	  ## Configs ##
	  
	  # TOML
	  taplo.enable = true;

	  # YAML
	  yamlls.enable = true;

	};
      };
    };
  };
}
