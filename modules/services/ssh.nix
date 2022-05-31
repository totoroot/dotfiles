{ options, config, pkgs, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.ssh;
in {
  options.modules.services.ssh = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      sshpass
    ];

    services.openssh = {
      enable = true;
      kbdInteractiveAuthentication = false;
      passwordAuthentication = false;
    };

    user.openssh.authorizedKeys.keys =
      if config.user.name == "mathym"
      then [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6pxS+faVh8CTTHw2ZZwnm9s54xNpDC6RJzxg43452g mathym@purple"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILplKT9yCU7in8VjPsxtxLZrhU8PajUJZascd0J4ILGv mathym@violet"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJe9HuM+MU/iO4QWVVmkTEZ79ybiKV1eCWXKx9wU8VKY mathym@lilac"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7TpDoH2+3kWlkU8Zjbdfqcs/Qrw+H00Oc/ElLyB81M matthias@notebook"
      ]
      else [];
  };
}
