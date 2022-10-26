# modules/desktop/vm/virt-manager.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.vm.virt-manager;
in {
  options.modules.desktop.vm.virt-manager = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Desktop user interface for managing virtual machines
      virt-manager
      # A toolkit to interact with the virtualization capabilities of recent versions of Linux and other OSes
      libvirt
    ];

    user.extraGroups = [ "libvirtd" ];

    virtualisation.libvirtd.enable = true;
  };
}
