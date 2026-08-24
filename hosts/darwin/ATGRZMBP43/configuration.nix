# nix-darwin configuration
{ pkgs, ... }:

{
  imports = [
    ./brew.nix
  ];

  users.users."matthias.thym" = {
    name = "matthias.thym";
    home = "/Users/matthias.thym";
  };

  system.primaryUser = "matthias.thym";

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "45.83.104.124:21042";
        sshUser = "builder";
        sshKey = "/Users/matthias.thym/.ssh/nix-builder-jam";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 12;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
        publicHostKey = builtins.concatStringsSep "" [
          "AAAAC3NzaC1lZDI1NTE5AAAAILpQeOZlcEkngp6n"
          "SLsaDSFFlfaCOwagK87nN3Xl96aU"
        ];
      }
    ];
    settings.builders-use-substitutes = true;
  };

  modules.darwin.containers.enable = true;

  launchd.user.agents.displayplacer-layout = {
    serviceConfig = {
      ProgramArguments = [
        "/Users/matthias.thym/.config/dotfiles/bin/displayplacer-autolayout"
      ];
      RunAtLoad = true;
      StartInterval = 10;
      StandardErrorPath = "/tmp/displayplacer-layout.err";
      StandardOutPath = "/tmp/displayplacer-layout.out";
    };
  };

  launchd.user.agents.ollama-serve = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.ollama}/bin/ollama"
        "serve"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/ollama-serve.err";
      StandardOutPath = "/tmp/ollama-serve.out";
    };
  };

}
