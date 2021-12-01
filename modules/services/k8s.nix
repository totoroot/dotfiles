{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.k8s;
in {
  options.modules.services.k8s = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Kubernetes CLI
      kubectl
      
      # Package manager for kubectl plugins
      krew
      
      # Utility to quickly switch between K8s clusters (kubectx) and namespaces (kubens)
      kubectx

      # Package manager for K8s charts
      kubernetes-helm

      # Deploy helm charts to defferent environments with ease 
      helmfile

      # Translate docker-compose files into K8s resources
      kompose

      # Kubernetes IDE
      lens
    ];

    env.KUBECONFIG = "$XDG_CONFIG_HOME/k8s";

    # user.extraGroups = [ "docker" ];

    modules.shell.zsh.rcFiles = [ "${configDir}/k8s/aliases.zsh" ];

    # virtualisation = {
      # docker = {
        # enable = true;
        # autoPrune.enable = true;
        # enableOnBoot = false;
        # # listenOptions = [];
      # };
    # };
  };
}
