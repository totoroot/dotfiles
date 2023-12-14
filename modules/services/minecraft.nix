{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.minecraft;
  domain = "xn--berwachungsbehr-mtb1g.de";
  minecraftPort = 25565;
in
{
  options.modules.services.minecraft = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      # Set to true if you agree to Mojang's EULA:
      # https://account.mojang.com/documents/minecraft_eula
      eula = false;
      declarative = true;

      # See here for more info: https://minecraft.gamepedia.com/Server.properties#server.properties
      serverProperties = {
        server-port = minecraftPort;
        gamemode = "survival";
        motd = "NixOS Minecraft server";
        max-players = 5;
        enable-rcon = true;
        # This password can be used to administer your minecraft server.
        # Exact details as to how will be explained later. If you want
        # you can replace this with another password.
        "rcon.password" = "admin";
        level-seed = "10292992";
      };
    };

    environment.systemPackages = [ config.services.vaultwarden.package ];
  };
}
