{ inputs, ... }: {
  imports = [ inputs.sops-nix.nixosModules.default ];

  sops = {
    age.keyFile = "/home/grant/.config/sops/age/keys.txt";

    secrets."hermes-env" = {
      sopsFile = ../nixos-configurations/nixos-desktop/sops/hermes-env.yaml;
      format = "yaml";
    };

    secrets."openrouter-key" = {
      sopsFile = ../nixos-configurations/nixos-desktop/sops/openrouter-key.yaml;
      format = "binary";
    };
  };
}
