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
      kubectl
      kubectx
      kubens
      kubernetes-helm
      helmfile
      kompose
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
