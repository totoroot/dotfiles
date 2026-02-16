{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.pass;
in
{
  options.modules.home.pass = with types; {
    enable = mkBoolOpt false;
    passwordStoreDir = mkOpt str "$HOME/.secrets/password-store";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (pass.withExtensions (exts: [
        exts.pass-otp
        exts.pass-genphrase
      ]))
    ];

    home.sessionVariables.PASSWORD_STORE_DIR = cfg.passwordStoreDir;
  };
}
