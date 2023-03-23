{ options, config, pkgs, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.ssh;
in {
  options.modules.services.ssh = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    programs.ssh.extraConfig = "IdentityFile ~/.ssh/${config.networking.hostName}";

    services.openssh = {
      enable = true;
      settings = {
        kbdInteractiveAuthentication = false;
        passwordAuthentication = false;
      };
    };

    user.packages = with pkgs; [
      sshpass
    ];

    user.openssh.authorizedKeys.keys =
      if config.user.name == "mathym"
      then [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6pxS+faVh8CTTHw2ZZwnm9s54xNpDC6RJzxg43452g mathym@purple"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILplKT9yCU7in8VjPsxtxLZrhU8PajUJZascd0J4ILGv mathym@violet"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIT5s6+Feov4htIAeAuAa4VNqpXFuXVUf+jgnxQ7alqp mathym@grape"
      ]
      else [];
  };
}
