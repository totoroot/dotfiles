# modules/shell/devops.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.devops;
in {
  options.modules.shell.devops = {
    enable  = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Automation tool
      unstable.ansible
      # Linter for ansible
      unstable.ansible-lint
      # Generate typed CustomResources from a Kubernetes CustomResourceDefinition
      unstable.crd2pulumi
      # Python-based infrastructure automation
      unstable.pyinfra
      # Cloud development platform that makes creating cloud programs easy and productive
      unstable.pulumi-bin
      # Tool for building, changing, and versioning infrastructure
      unstable.terraform
      # CLI tool to generate terraform files from existing infrastructure (reverse Terraform). Infrastructure to Code
      unstable.terraformer
    ];
  };
}
