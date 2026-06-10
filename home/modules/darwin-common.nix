{ config, lib, pkgs, ... }:

let
  cfg = config.modules.home.darwinCommon;
in
{
  options.modules.home.darwinCommon = {
    enable = lib.mkEnableOption "common Darwin Home Manager defaults";

    hostName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    defaultUser = lib.mkOption {
      type = lib.types.str;
      default = "mathym";
    };

    firefoxProfileDirectory = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    enableBitwarden = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    enableContainers = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    enableGhostty = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      coreutils
      cachix
      niv
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      cocoapods
      m-cli
    ];

    home.sessionVariables = {
      HOMEBREW_NO_INSTALL_CLEANUP = "TRUE";
      EDITOR = "micro";
    };

    home.sessionPath = [
      "$HOME/.config/dotfiles/bin"
    ];

    modules.home.unfreePackages.enable = true;
    modules.home.atuin.enable = true;
    modules.home.bitwarden.enable = cfg.enableBitwarden;
    modules.home.containers.enable = cfg.enableContainers;
    modules.home.duf.enable = true;
    modules.home.git.enable = true;
    modules.home.fonts.enable = true;
    modules.home.ghostty.enable = cfg.enableGhostty;
    modules.home.helix.enable = true;
    modules.home.kitty.enable = true;
    modules.home.kubernetes.enable = true;
    modules.home.lf.enable = true;
    modules.home.llm.enable = true;
    modules.home.micro.enable = true;
    modules.home.modernShell.enable = true;
    modules.home.nushell.enable = false;
    modules.home.sshHosts = {
      enable = true;
      hostName = cfg.hostName;
      defaultUser = cfg.defaultUser;
    };
    modules.home.trash.enable = true;
    modules.home.viddy.enable = true;
    modules.home.zsh.enable = true;

    modules.home.firefox = lib.mkIf (cfg.firefoxProfileDirectory != null) {
      enable = true;
      profileDirectory = cfg.firefoxProfileDirectory;
    };

    home.file = {
      "Library/Keyboard Layouts/EurKEY.keylayout".source = ../../config/eurkey/EurKEY.keylayout;
      "Library/Keyboard Layouts/EurKEY.icns".source = ../../config/eurkey/EurKEY.icns;
      "Applications/kitty.app/Contents/Resources/kitty.icns".source = ../../config/kitty/kitty-dark.icns;
      ".hushlogin".text = "";
    };
  };
}
