{ pkgs, ... }:
{
  user.packages = with pkgs; [
    # GTK3 & python based GUI for Syncthing
    syncthing-gtk
  ];
}
