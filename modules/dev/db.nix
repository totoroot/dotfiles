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
      python38
      # Scientific tools for Python
      python38Packages.numpy
      # Python Data Analysis Library
      python38Packages.pandas
      # Python SQL toolkit and Object Relational Mapper
      python38Packages.sqlalchemy
      # Universal SQL Client for developers, DBA and analysts
      dbeaver
      # Self-contained, serverless, zero-configuration, transactional SQL database engine
      sqlite
      # Python CLI utility and library for manipulating SQLite databases
      sqlite-utils
    ];
  };
}
