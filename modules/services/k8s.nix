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
      # Kubernetes CLI To manage your clusters in style
      k9s
      # Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML documents
      yq
    ];

    # Set the K8s config location
    env.KUBECONFIG = "$XDG_CONFIG_HOME/k8s";
    # This is needed to run installed plugins
    env.PATH = [ "$HOME/.krew/bin" ];

    # Source a bunch of aliases for handling K8s without getting finger cramps
    modules.home.zsh.rcFiles = [ "${configDir}/k8s/aliases.zsh" ];

    home.configFile = {
      "k9s/config.yml".source = "${configDir}/k9s/config.yml";
      "k9s/skin.yml".source = "${configDir}/k9s/skin.yml";
    };

    environment.shellAliases = {
      hf = "helmfile";
      hfi = "helmfile --interactive";
      # Based on https://sbulav.github.io/kubernetes/using-fzf-with-kubectl/
      kyq = ''(){
        kubectl get $@ -o yaml > /tmp/kyq.yaml; echo "" | fzf --print-query \
                                                              --preview-window=right,60% \
                                                              --preview "yq .{q} /tmp/kyq.yaml -y | bat --language yaml --color=always --style=numbers";
      }'';
      kf = ''(){
        kubectl get $@ -o name | fzf --print-query \
                                     --preview-window=right,60% \
                                     --preview "kubectl get {} -o yaml | bat --language yaml --color=always --style=numbers" \
                                     --header "Press <Ctrl>-<R> to reload, <Ctrl>-<E> to edit, <Enter> to view in micro." \
                                     --bind "ctrl-r:reload(kubectl get $@ -o name)" \
                                     --bind "ctrl-e:execute(kubectl edit {+})" \
                                     --bind "enter:execute(kubectl get {+} -o yaml | micro -filetype yaml)";
      }'';
    };
  };
}
