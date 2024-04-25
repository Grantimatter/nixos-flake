# Grantimatter's NixOS and Home-Manager configuration

## Usefull Tools
- [ez-configs](https://github.com/ehllie/ez-configs) - Picks up configs from flake directory instead of having to manually add / import them to the base config.
- [age](https://github.com/FiloSottile/age) - File encryption. Usefull for working with secrets in your config.
- [sops-nix](https://github.com/Mic92/sops-nix) - Great for working with encrypted files, pairs great with age. When setup with encryption keys, allows you to open / edit and save encrypted files.

## Common Pitfalls
- When using nix flakes, only files tracked with git are evaluated when rebuilding.

## Common Commands
### Rebuild NixOS configuration
```sh
sudo nixos-rebuild switch --flake .#<host>

# Alias
nixosSwitch
```

### Rebuild Home Manager configuration
```sh
home-manager switch --flake .#<username>@<host>

# Alias
homeSwitch
```

### Open / Create Encrypted Files
**Assuming you already have an age key that sops can use**

```sh
# Enter the dev shell
nix develop

# Sops will open the file with your default editor
sops ./secrets/<file>
```

## General Tips
TODO
