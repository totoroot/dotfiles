{ ... }:

{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
    ./mounts.nix
    ./home.nix
  ];

  modules = {
    theme.active = "dracula";
    desktop = {
      environments = {
        bspwm.enable = true;
        hyprland.enable = true;
        kde-plasma.enable = true;
      };
      backup.enable = true;
      clipboard.enable = true;
      documents.enable = true;
      fonts.enable = true;
      flatpak.enable = true;
      keepassxc.enable = true;
      kvantum.enable = true;
      mail.enable = true;
      plank.enable = true;
      screenshot.enable = true;
      fm.enable = true;
      mapping.enable = true;
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
        polish.enable = true;
        rofi.enable = true;
        torrent.enable = true;
        vscodium.enable = true;
      };
      browsers = {
        default = "firefox";
        chromium.enable = true;
        firefox.enable = true;
        lynx.enable = true;
        tor.enable = false;
      };
      communication = {
        delta.enable = false;
        discord.enable = true;
        jitsi.enable = false;
        matrix.enable = true;
        signal.enable = true;
        telegram.enable = true;
      };
      gaming = {
        retro.enable = true;
        steam.enable = true;
      };
      media = {
        audio.enable = true;
        daw.enable = true;
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
      lua.enable = true;
      node.enable = false;
      python.enable = true;
      rust.enable = true;
      scala.enable = true;
    };
    editors = {
      default = "hx";
      helix.enable = true;
      micro.enable = true;
      vim.enable = true;
    };
    hardware = {
      pulseaudio.enable = false;
      bluetooth.enable = true;
      disks.enable = true;
      fancontrol.enable = true;
      image.enable = true;
      keebs.enable = true;
      mcus.enable = true;
      nvidia.enable = false;
      radeon.enable = true;
      printers.enable = true;
      sensors.enable = true;
      steamcon.enable = true;
      wacom.enable = true;
    };
    shell = {
      archive.enable = true;
      borg.enable = true;
      devops.enable = true;
      direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      iperf.enable = true;
      lf.enable = true;
      aerc.enable = true;
      pass.enable = true;
      taskell.enable = false;
      zsh.enable = true;
      nu.enable = true;
      cli.enable = true;
    };
    services = {
      containerization.enable = true;
      containers = {
        snowflake.enable = false;
      };
      pods = {
        languagetool.enable = true;
        penpot.enable = true;
        scrutiny.enable = true;
        vaultwarden.enable = true;
      };
      gitea.enable = false;
      jellyfin.enable = false;
      kdeconnect.enable = true;
      k8s.enable = true;
      nginx.enable  = false;
      vpn.enable = true;
      ssh.enable = true;
      syncthing.enable = true;
      transmission.enable     = false;
    };
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

  # Force DPI to optimize for ultrawide screen
  services.xserver.dpi = 200;

  # Set default monitor
  environment.variables = rec {
    MONITORS = ["HDMI-0" "DP-0"];
  };

  programs.dconf.enable = true;
}
