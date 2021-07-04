{ ... }:

{
  ## System security tweaks
  boot.tmpOnTmpfs = true;
  security.protectKernelImage = true;

  # Set sudo command timeout to 60 minutes
  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=60
  '';

  # Fix a security hole in place for backwards compatibility. See desc in
  # nixpkgs/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix
  boot.loader.systemd-boot.editor = false;

  # Change me later!
  user.initialPassword = "nixos";
  users.users.root.initialPassword = "nixos";
}
