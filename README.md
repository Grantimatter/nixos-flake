# Grantimatter's NixOS and Home-Manager Configuration

## Setup
1. Install / boot NixOS.
2. Clone repo.
3. Run `$ sudo nixos-rebuild switch --flake .#<host>` - The host will be one of the configurations in `./nixos-configurations`.

## Setup with secrets
1. Follow normal setup steps.
2. Run `$ nix develop` or alias `nixdev`.
3. Generate or get previous age key and place in `$ $XDG_CONFIG_HOME/sops/keys/age/keys.txt`.
4. Open or create secrets file in the `./sops` directory. `$ sops ./sops/<secret>.yaml|json|env|ini|toml`

After those steps, you should be able to use the encrypted secrets in the NixOS and Home Manager configurations. See [sops-nix](https://github.com/Mic92/sops-nix) for more info.

## Usefull Tools
- [ez-configs](https://github.com/ehllie/ez-configs) - Picks up configs from flake directory instead of having to manually add / import them to the base config.
  I recommend checking out [ehllie's dotfiles](https://github.com/ehllie/dotfiles/blob/main/flake.nix) as their module setup is probably better than this repo in it's current state.
  
- [age](https://github.com/FiloSottile/age) - File encryption. Usefull for working with secrets in your config.

- [sops-nix](https://github.com/Mic92/sops-nix) - Great for working with encrypted files, pairs great with age. When setup with encryption keys, allows you to open / edit and save encrypted files.

## Common Pitfalls
- When using nix flakes, only files tracked with git are evaluated when rebuilding.

## Common Commands
### Rebuild NixOS configuration
```sh-session
$ sudo nixos-rebuild switch --flake .#<host>

# Alias
$ nixosSwitch
```

### Rebuild Home Manager configuration
```sh-session
$ home-manager switch --flake .#<username>@<host>

# Alias
$ homeSwitch
```
