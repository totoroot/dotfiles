# modules/shell/devops.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.devops;
in {
  options.modules.shell.devops = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Automation tool
      ansible
      # Linter for ansible
      ansible-lint
      # Generate typed CustomResources from a Kubernetes CustomResourceDefinition
      crd2pulumi
      # Python-based infrastructure automation
      pyinfra
      # Cloud development platform that makes creating cloud programs easy and productive
      pulumi-bin
      # Tool for building, changing, and versioning infrastructure
      terraform
      # CLI tool to generate terraform files from existing infrastructure (reverse Terraform). Infrastructure to Code
      terraformer
      # Like cURL, but for gRPC: Command-line tool for interacting with gRPC servers
      grpcurl
      google-cloud-bigtable-tool
    ];
  };
}
