{ config, lib, pkgs, ... }:

let
  cfg = config.modules.home.firefox;
  profileBasePath = if pkgs.stdenv.isDarwin then "Library/Application Support/Firefox/Profiles" else ".mozilla/firefox";
  profilePath = "${profileBasePath}/${cfg.profileDirectory}";
  mkExtensionFile = ext: {
    name = "${profilePath}/extensions/${ext.id}.xpi";
    value.source = pkgs.fetchurl {
      url = ext.url;
      sha256 = ext.sha256;
    };
  };
  userJsText = ''
    ${lib.concatStrings (lib.mapAttrsToList (name: value: ''
      user_pref("${name}", ${builtins.toJSON value});
    '') cfg.settings)}
    ${cfg.extraConfig}
  '';
in
{
  options.modules.home.firefox = with lib.types; {
    enable = lib.mkEnableOption "declarative Firefox profile files";

    package = lib.mkOption {
      type = package;
      default = pkgs.firefox;
      description = "Firefox package to install.";
    };

    profileDirectory = lib.mkOption {
      type = str;
      default = "default-release";
      description = "Firefox profile directory name. On Darwin this is under ~/Library/Application Support/Firefox/Profiles/, on Linux under ~/.mozilla/firefox/. Set it to the full active profile directory name.";
    };

    settings = lib.mkOption {
      type = attrsOf (oneOf [ bool int str ]);
      default = {
        "devtools.theme" = "dark";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.download.dir" = "$HOME/dl";
        "signon.rememberSignons" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.newtabpage.enabled" = true;
        "browser.newtab.url" = "about:blank";
        "browser.newtabpage.activity-stream.enabled" = false;
        "browser.newtabpage.enhanced" = false;
        "browser.newtab.preload" = false;
        "browser.newtabpage.directory.ping" = "";
        "browser.newtabpage.directory.source" = "data:text/plain,{}";
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.htmlaboutaddons.discover.enabled" = false;
        "extensions.pocket.enabled" = false;
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";
        "extensions.shield-recipe-client.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "dom.battery.enabled" = false;
        "beacon.enabled" = false;
        "browser.send_pings" = false;
        "dom.gamepad.enabled" = false;
        "browser.fixup.alternate.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "experiments.supported" = false;
        "experiments.enabled" = false;
        "experiments.manifest.uri" = "";
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
      };
      description = "Firefox preferences to set in user.js.";
    };

    extraConfig = lib.mkOption {
      type = lines;
      default = "";
      description = "Extra lines to append to user.js.";
    };

    userChrome = lib.mkOption {
      type = lines;
      default = ''
        #main-window #TabsToolbar {
          visibility: collapse !important;
        }

        /* floating urlbar */
        #urlbar[breakout][breakout-extend] {
          top: 200px !important;
          left: 50% !important;
          max-width: 900px !important;
          width: 90% !important;
          transform: translateX(-50%);
          padding: 7px !important;
          font-size: 18px !important;
        }
      '';
      description = "CSS for Firefox userChrome.css.";
    };

    extraUserChrome = lib.mkOption {
      type = lines;
      default = "";
      description = "Additional CSS appended to Firefox userChrome.css, e.g. from theme modules.";
    };

    userContent = lib.mkOption {
      type = lines;
      default = "";
      description = "CSS for Firefox userContent.css.";
    };

    extensions = lib.mkOption {
      type = listOf (submodule {
        options = {
          id = lib.mkOption {
            type = str;
            description = "Firefox extension ID used as the XPI filename.";
          };
          url = lib.mkOption {
            type = str;
            description = "Direct URL to the pinned .xpi artifact.";
          };
          sha256 = lib.mkOption {
            type = str;
            description = "SHA-256 hash of the pinned .xpi artifact.";
          };
        };
      });
      default = [
        # Bitwarden releases/changelog:
        # - AMO: https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/
        # - Upstream: https://bitwarden.com
        {
          id = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4749958/bitwarden_password_manager-2026.3.0.xpi";
          sha256 = "sha256-LcbQdNTcCr0qiWb1BlpV5yUrv15Usjwx2+2r+sDU28Q=";
        }
        # Sidebery releases/changelog:
        # - AMO: https://addons.mozilla.org/en-US/firefox/addon/sidebery/
        # - Upstream: https://github.com/mbnuqw/sidebery
        {
          id = "{3c078156-979c-498b-8990-85f7987dd929}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4688454/sidebery-5.5.0.xpi";
          sha256 = "sha256-jVetNRd0QvaonD0xn6PgWGN2ofK3Lw/TAyOG5fNQXbg=";
        }
        # I still don't care about cookies releases/changelog:
        # - AMO: https://addons.mozilla.org/en-US/firefox/addon/istilldontcareaboutcookies/
        # - Upstream: https://github.com/OhMyGuus/I-Dont-Care-About-Cookies
        {
          id = "idcac-pub@guus.ninja";
          url = "https://addons.mozilla.org/firefox/downloads/file/4637154/istilldontcareaboutcookies-1.1.9.xpi";
          sha256 = "sha256-QpIvYc/FPiED5JLdvlc2yvUD2drUqIaQ78TGTawQ1cc=";
        }
        # Privacy Badger releases/changelog:
        # - AMO: https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/
        # - Upstream: https://privacybadger.org/
        {
          id = "jid1-MnnxcxisBPnSXQ@jetpack";
          url = "https://addons.mozilla.org/firefox/downloads/file/4700632/privacy_badger17-2026.2.20.xpi";
          sha256 = "sha256-7qSfFGHeXrAOsXsisoZLVbVKy1d7A2BodGD+mCYz+9Y=";
        }
        # Cookie AutoDelete releases/changelog:
        # - AMO: https://addons.mozilla.org/en-US/firefox/addon/cookie-autodelete/
        # - Upstream: https://github.com/Cookie-AutoDelete/Cookie-AutoDelete
        {
          id = "CookieAutoDelete@kennydo.com";
          url = "https://addons.mozilla.org/firefox/downloads/file/4040738/cookie_autodelete-3.8.2.xpi";
          sha256 = "sha256-sCQ4ql3yp563Q9obYpuA2MSBFMnQMKu1U4tZF1TjD3Q=";
        }
        # LocalCDN releases/changelog:
        # - AMO: https://addons.mozilla.org/en-US/firefox/addon/localcdn-fork-of-decentraleyes/
        # - Upstream: https://codeberg.org/nobody/LocalCDN
        {
          id = "{b86e4813-687a-43e6-ab65-0bde4ab75758}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4709745/localcdn_fork_of_decentraleyes-2.6.84.xpi";
          sha256 = "sha256-7FICLYvw546HPSzVVIic2rFP5F0ieBqBgeTEYSJ9ZmU=";
        }
        # uBlock Origin releases/changelog:
        # - AMO: https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/
        # - Upstream: https://github.com/gorhill/uBlock#ublock-origin
        {
          id = "uBlock0@raymondhill.net";
          url = "https://addons.mozilla.org/firefox/downloads/file/4721638/ublock_origin-1.70.0.xpi";
          sha256 = "sha256-8nMNKHcAV2OkXXZXSYkuk29JyucT0o96puoxRFS4nPE=";
        }
      ];
      description = "Extensions to install declaratively into the selected Firefox profile.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.file =
      (builtins.listToAttrs (map mkExtensionFile cfg.extensions))
      // {
        "${profilePath}/user.js" = lib.mkIf (cfg.settings != { } || cfg.extraConfig != "") {
          text = userJsText;
        };
        "${profilePath}/chrome/userChrome.css" = lib.mkIf (cfg.userChrome != "" || cfg.extraUserChrome != "") {
          text = cfg.userChrome + "\n" + cfg.extraUserChrome;
        };
        "${profilePath}/chrome/userContent.css" = lib.mkIf (cfg.userContent != "") {
          text = cfg.userContent;
        };
      };
  };
}
