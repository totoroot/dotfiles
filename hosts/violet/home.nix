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
    home.file = {
      "Notes/".source = config.lib.file.mkOutOfStoreSymlink "/home/mathym/Sync/notes/";
      "Pictures/photos".source = config.lib.file.mkOutOfStoreSymlink "/mnt/photos/";
      "Trash/".source = config.lib.file.mkOutOfStoreSymlink "/home/mathym/.local/share/Trash/files/";
    };
  };
}
