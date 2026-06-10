{ ... }:

{
  imports = [
    ./brew.nix
  ];

  users.users."mathym" = {
    name = "mathym";
    home = "/Users/mathym";
  };

  system.primaryUser = "mathym";

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
}
