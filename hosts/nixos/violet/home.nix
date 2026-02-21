{ config, home-manager, ... }:

{
  home.file = {
    "Desktop/.use".text = "desktop";
    "Dev/.use".text = "development";
    "Downloads/.use".text = "downloads";
    "Pictures/.use".text = "photos and graphics";
    "Public/.use".text = "shared files";
    "Sync/.use".text = "synchronised files";
    "Sync/notes/.use".text = "notes";
    "Temp/.use".text = "temporary files";
    "Videos/.use".text = "videos";
  };

  home-manager.users.${config.user.name} = { config, ... }: {
    imports = [
      ../../../home/bridge.nix
    ];

    modules.home = {
      unfreePackages.enable = true;
      archive.enable = true;
      atuin.enable = true;
      borg.enable = true;
      duf.enable = true;
      git.enable = true;
      helix.enable = true;
      lf.enable = true;
      micro.enable = true;
      nushell.enable = true;
      sshHosts.enable = true;
      trash.enable = true;
      viddy.enable = true;
      zsh.enable = true;
    };

    home.file = {
      "Notes/".source = config.lib.file.mkOutOfStoreSymlink "/home/mathym/Sync/notes/";
      "Pictures/photos".source = config.lib.file.mkOutOfStoreSymlink "/mnt/photos/";
      "Trash/".source = config.lib.file.mkOutOfStoreSymlink "/home/mathym/.local/share/Trash/files/";
    };
  };
}
