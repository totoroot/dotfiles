{ config, home-manager, ... }:

{
  home.file = {
    "Desktop/.use".text = "desktop";
    "Development/.use".text = "development";
    "Documents/.use".text = "documents";
    "Downloads/.use".text = "downloads";
    "Games/.use".text = "games";
    # "Music/.use".text = "music";
    "Pictures/.use".text = "photos and graphics";
    "Public/.use".text = "shared files";
    "Resources/.use".text = "resources";
    "Sync/.use".text = "synchronised files";
    "Sync/notes.use".text = "notes";
    "Temp/.use".text = "temporary files";
    "Videos/.use".text = "videos";
  };

  home-manager.users.${config.user.name} = { config, ... }: {
    home.file = {
      "Notes/".source = config.lib.file.mkOutOfStoreSymlink "/home/mathym/Sync/notes/";
      "Trash/".source = config.lib.file.mkOutOfStoreSymlink "/home/mathym/.local/share/Trash/files/";
      "Pictures/photos".source = config.lib.file.mkOutOfStoreSymlink "/mnt/photos/";
      "Music".source = config.lib.file.mkOutOfStoreSymlink "/mnt/music/";
    };
  };
}
