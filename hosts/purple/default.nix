{ ... }:
{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
  ];

  ## Modules
  modules = {
    desktop = {
      gaming = {
        retro.enable = true;
      };
      bspwm.enable = true;
      documents.enable = true;
      fonts.enable = true;
      flatpak.enable = true;
      keepassxc.enable = true;
      kvantum.enable = true;
      screenshot.enable = true;
      thunar.enable = true;
      apps = {
        anki.enable = true;
        blender.enable = true;
        calibre.enable = true;
        ide.enable = true;
        ghostwriter.enable = true;
        godot.enable = true;
        gpa.enable = true;
        gsmartcontrol.enable = true;
        nextcloud.enable = true;
        rofi.enable = true;
        torrent.enable = true;
        vscodium.enable = true;
      };
      browsers = {
        default = "firefox";
        chromium.enable = true;
        firefox.enable = true;
        lynx.enable = true;
        qutebrowser.enable = false;
        tor.enable = false;
      };
      communication = {
        delta.enable = true;
        discord.enable = false;
        jitsi.enable = true;
        matrix.enable = true;
        signal.enable = true;
        telegram.enable = true;
      };
      media = {
        audio.enable = true;
        daw.enable = false;
        graphics.enable = true;
        kodi.enable = true;
        ncmpcpp.enable = false;
        video = {
          editing.enable = true;
          player.enable = true;
          recording.enable = true;
          transcoding.enable = true;
        };
      };
      term = {
        default = "kitty";
        st.enable = true;
        kitty.enable = true;
      };
      vm = {
        qemu.enable = true;
        virtualbox.enable = false;
        virt-manager.enable = true;
      };
    };
    dev = {
      cc.enable = true;
      clojure.enable = false;
      common-lisp.enable = false;
      db.enable = true;
      go.enable = true;
      java.enable = true;
      julia.enable = true;
      lua.enable = false;
      node.enable = false;
      python.enable = true;
      rust.enable = true;
      scala.enable = false;
    };
    editors = {
      default = "micro";
      vim.enable = true;
      micro.enable = true;
    };
    hardware = {
      audio.enable = true;
      bluetooth.enable = true;
      disks.enable = true;
      fancontrol.enable = true;
      keebs.enable = true;
      mcus.enable = true;
      nvidia.enable = true;
      printers.enable = true;
      sensors.enable = true;
      steamcon.enable = true;
      wacom.enable = true;
    };
    shell = {
      archive.enable = true;
      borg.enable = true;
      clipboard.enable = true;
      direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      lf.enable = true;
      mail.enable = true;
      pass.enable = true;
      taskell.enable  = true;
      zsh.enable = true;
      cli.enable = true;
    };
    services = {
      containers.enable = true;
      gitea.enable = false;
      jellyfin.enable = false;
      kdeconnect.enable = true;
      k8s.enable = true;
      nginx.enable  = false;
      vpn.enable = true;
      ssh.enable = true;
      transmission.enable	= false;
    };
    theme.active = "quack";
  };

  ## Local config
  programs.ssh.startAgent = true;
  services.openssh.startWhenNeeded = true;
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false
  # here. Per-interface useDHCP will be mandatory in the future, so this
  # generated config replicates the default behaviour.
  networking.useDHCP = false;

  # Set eurkey as default layout
  # Optionally set more keymaps and use them with bin/keymapswitcher
  services.xserver.layout = "eu";

  # Set default monitor
  environment.variables = rec {
    MONITORS = ["HDMI-0" "DP-0"];
  };

  # Create some home directories
  home.file = {
    "archive/.use".text = "archive";
    "books/.use".text = "books";
    "dev/.use".text = "dev";
    "documents/.use".text = "documents";
    "downloads/.use".text = "downloads";
    "graphics/.use".text = "graphics";
    "inbox/.use".text = "inbox";
    "music/.use".text = "music";
    "notes/.use".text = "notes";
    "outbox/.use".text = "outbox";
    "photos/.use".text = "photos";
    "resources/.use".text = "resources";
    "shared/.use".text = "shared";
    "tmp/.use".text = "tmp";
    "uni/.use".text = "uni";
    "zero/.use".text = "zero";
  };
}
