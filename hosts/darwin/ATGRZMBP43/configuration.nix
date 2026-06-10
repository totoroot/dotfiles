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
