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
      # Customization of K8s YAML configurations
      kustomize
      # Package manager for K8s charts
      kubernetes-helm
      # Helm plugin that shows a diff
      #kubernetes-helmPlugins.helm-diff
      # Helm plugin that helps manage secrets
      #kubernetes-helmPlugins.helm-secrets
      # Deploy helm charts to different environments with ease
      helmfile
      # Translate docker-compose files into K8s resources
      kompose
      # Colorizes kubectl output
      kubecolor
      # Tool that makes it easy to run Kubernetes locally
      minikube
      # Kubernetes CLI To Manage Your Clusters In Style
      k9s
    ];

    # Set the K8s config location
    env.KUBECONFIG = "$XDG_CONFIG_HOME/k8s";
    # This is needed to run installed plugins
    env.PATH = [ "$HOME/.krew/bin" ];

    # Source a bunch of aliases for handling K8s without getting finger cramps
    modules.shell.zsh.rcFiles = [ "${configDir}/k8s/aliases.zsh" ];

    home.configFile = {
      "k9s/config.yml".source = "${configDir}/k9s/config.yml";
      "k9s/skin.yml".source = "${configDir}/k9s/skin.yml";
    };

    environment.shellAliases = {
      hf = "helmfile";
      hfi = "helmfile --interactive";
    };
  };
}
