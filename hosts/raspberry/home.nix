{ ... }:
{
  home.file = {
    "dev/.use".text = "development";
    "dls/.use".text = "downloads";
    "nts/.use".text = "notes";
    "tmp/.use".text = "temporary files";
    "trash/".source = "/home/mathym/.local/share/Trash/files/";
  };
}
