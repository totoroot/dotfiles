# modules/dev/db.nix

{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let cfg = config.modules.dev.db;
in {
  options.modules.dev.db = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Universal SQL Client for developers, DBA and analysts
      dbeaver-bin
      # Self-contained, serverless, zero-configuration, transactional SQL database engine
      sqlite
      # Python CLI utility and library for manipulating SQLite databases
      sqlite-utils
      # Graphical FTP, FTPS and SFTP client
      filezilla
    ];
  };
}
