{ ... }:
{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
  ];

  ## Modules
  modules = {
    desktop = {
      bspwm.enable = true;
      documents.enable = false;
      fonts.enable = true;
      flatpak.enable = false;
      keepassxc.enable = true;
      kvantum.enable = false;
      screenshot.enable = false;
      thunar.enable = true;
      apps = {
        anki.enable = false;
        blender.enable = false;
        calibre.enable = false;
        geany.enable = false;
        ghostwriter.enable = false;
        godot.enable = false;
        gpa.enable = false;
        gsmartcontrol.enable = false;
        nextcloud.enable = false;
        rofi.enable = true;
        torrent.enable = false;
        vscodium.enable = false;
      };
      browsers = {
        default = "firefox";
        chromium.enable = false;
        firefox.enable = true;
        qutebrowser.enable = false;
        tor.enable = false;
      };
      communication = {
        delta.enable = false;
        discord.enable = false;
        jitsi.enable = false;
        matrix.enable = false;
        signal.enable = false;
        telegram.enable = false;
      };
      media = {
        graphics.enable = false;
        video.enable = false;
        audio.enable = true;
        daw.enable = false;
      };
      term = {
        default = "kitty";
        st.enable = true;
        kitty.enable = true;
      };
      vm = {
        qemu.enable = false;
        virtualbox.enable = false;
        virt-manager.enable = false;
      };
    };
    dev = {
      cc.enable = false;
      clojure.enable = false;
      common-lisp.enable = false;
      go.enable = false;
      java.enable = false;
      julia.enable = false;
      lua.enable = false;
      node.enable = false;
      python.enable = false;
      rust.enable = false;
      scala.enable = false;
      shell.enable = true;
    };
    editors = {
      default = "micro";
      vim.enable = false;
      micro.enable = true;
    };
    hardware = {
      audio.enable = true;
      bluetooth.enable = true;
      disks.enable = true;
      fancontrol.enable = true;
      keebs.enable = true;
      nvidia.enable = false;
      printers.enable = true;
      sensors.enable = true;
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
      taskell.enable = true;
      zsh.enable = true;
      cli.enable = true;
    };
    services = {
      docker.enable = true;
      gitea.enable = false;
      jellyfin.enable	= false;
      k8s.enable = false;
      nginx.enable = false;
      vpn.enable = false;
      ssh.enable = true;
      transmission.enable = false;
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
    MONITORS = ["HDMI-A-0"];
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
