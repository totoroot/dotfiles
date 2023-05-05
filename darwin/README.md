# Darwin Setup

To setup Nix and nix-darwin to be able to then use these dotfiles for configuration management on a system runnning macOS, follow these instructions:

## Install Nix (multi-user mode):
```
curl -L https://nixos.org/nix/install | sh
```


## Enable nix-command and flakes to bootstrap 
```
cat <<EOF > ~/.config/nix/nix.conf
experimental-features = nix-command flakes
EOF
```


## Install homebrew:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```


## Backup Nix default config

Until [this](https://github.com/LnL7/nix-darwin/issues/149) is addressed.

```
sudo mv /etc/nix/nix.conf /etc/nix/.nix-darwin.bkp.nix.conf
```


## Update Nix channels

```
nix-channel --update
```


# Update flake inputs

```
nix flake update
```


## Build the configuration
```
nix build .#darwinConfigurations.macbook.system
```


## Switch to new configuration

```
./result/sw/bin/darwin-rebuild switch --flake .
```
