{ pkgs, ... }:

{
  imports = [
    ./brew.nix
  ];

  users.users."mathym" = {
    name = "mathym";
    home = "/Users/mathym";
  };

  system.primaryUser = "mathym";

  modules.darwin.containers.enable = true;

  launchd.user.agents.displayplacer-layout = {
    serviceConfig = {
      ProgramArguments = [
        "~/.config/dotfiles/bin/displayplacer-autolayout"
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
