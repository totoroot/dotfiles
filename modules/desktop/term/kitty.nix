{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.term.kitty;
in {
  options.modules.desktop.term.kitty = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Modern, hackable, featureful, OpenGL based terminal emulator
      kitty
      # Graphical pdf (and epub, cbz, ...) reader that works inside the kitty terminal
      termpdfpy
    ];

    home.configFile = {
      "kitty/kitty.conf".source = "${configDir}/kitty/kitty.conf";
      "kitty/open-actions.conf".source = "${configDir}/kitty/open-actions.conf";
    };

    environment.shellAliases = {
      # Set terminfo for xterm-kitty when establishing SSH connection
      kssh = "kitty +kitten ssh";
      # Display images inside kitty
      # https://sw.kovidgoyal.net/kitty/kittens/icat/
      icat = "kitty +kitten icat";
      # Hyperlinked grep
      # https://sw.kovidgoyal.net/kitty/kittens/hyperlinked_grep/
      hg = "kitty +kitten hyperlinked_grep";
    };
  };
}
