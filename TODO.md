# TODO

- Fix Home Manager config symlink strategy on hosts like `jam` where GC can break user-space config.
- Root cause: `home/modules/config-symlinks.nix` uses `mkOutOfStoreSymlink` for many critical files, and some evaluated source paths end up under `/nix/store/...-source/`. After garbage collection, those targets disappear while the symlinks in `$HOME/.config` remain.
- Symptoms seen on `jam`:
  - missing `~/.config/atuin/config.toml`
  - missing `~/.config/zsh/config.zsh`, `keybinds.zsh`, `completion.zsh`, `aliases.zsh`, `extract.zsh`, `prompt.zsh`
  - `~/.config/zsh/extra.zshrc` sourcing vanished store paths like `/nix/store/...-source/config/git/aliases.zsh`
- Short-term mitigation already implemented:
  - `home/modules/zsh.nix` now sources `rcFiles` / `envFiles` only if they exist, so shell startup degrades gracefully instead of erroring hard.
- Proper fix to do later:
  - stop using `mkOutOfStoreSymlink` for critical Home Manager-managed config
  - make HM own those files in the generation instead of linking to GC-able source trees
  - likely rework `home/modules/config-symlinks.nix` and affected modules (`zsh`, `atuin`, `git`, etc.)
