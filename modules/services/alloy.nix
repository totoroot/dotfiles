{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.alloy;
in
{
  options.modules.services.alloy = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.alloy = {
      enable = true;
      configPath = pkgs.writeText "alloy-config.alloy" ''
        loki.write "default" {
          endpoint {
            url = "http://127.0.0.1:3100/loki/api/v1/push"
          }
        }

        // Normalize journald metadata into stable Loki labels for fast queries.
        loki.relabel "journal" {
          forward_to = [loki.process.mail.receiver, loki.write.default.receiver]

          rule {
            action = "replace"
            source_labels = ["service_name"]
            target_label = "unit"
          }

          rule {
            action = "replace"
            source_labels = ["__journal__transport"]
            target_label = "transport"
          }

          rule {
            action = "replace"
            source_labels = ["__journal_priority_keyword"]
            target_label = "level"
          }
        }

        // Add dedicated mail stream labels for postfix/dovecot logs.
        loki.process "mail" {
          forward_to = [loki.write.default.receiver]

          stage.match {
            selector = "{service_name=~\"postfix.*|dovecot2.service\"}"

            stage.static_labels {
              values = {
                stream = "mail",
                job = "mail",
                host_id = "${config.networking.hostName}",
                filename = "/var/mail/mail.log",
              }
            }
          }
        }

        loki.source.journal "systemd" {
          max_age    = "24h"
          forward_to = [loki.relabel.journal.receiver]
          labels = {
            job  = "systemd-journal",
            host = "${config.networking.hostName}",
          }
        }
      '';
    };

    systemd.services.alloy.after = [ "loki.service" ];
    systemd.services.alloy.wants = [ "loki.service" ];
  };
}
