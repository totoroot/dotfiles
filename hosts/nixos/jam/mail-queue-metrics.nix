{ config, pkgs, ... }:
let
  metricsDir = "/var/lib/postfix-queue-metrics";
  collect = pkgs.writeShellApplication {
    name = "collect-postfix-queue-metrics";
    runtimeInputs = [ pkgs.coreutils pkgs.jq ];
    text = ''
      umask 077
      output=$(mktemp "${metricsDir}/.postfix-queue.XXXXXXXX")
      trap 'rm -f -- "$output"' EXIT

      # Extract aggregate counts only. The queue listing can contain addresses.
      if ! ${config.security.wrapperDir}/postqueue -j 2>/dev/null | jq -rs '
        if all(.[]; (.queue_id | type == "string") and
                    (.queue_name | type == "string") and
                    (.arrival_time | type == "number")) then
          (unique_by(.queue_id)) as $queue |
          (now | floor) as $now |
          ["# TYPE postfix_queue_messages gauge",
           "postfix_queue_messages \($queue | length)",
           "# TYPE postfix_queue_deferred_messages gauge",
           "postfix_queue_deferred_messages \($queue | map(select(.queue_name == "deferred")) | length)",
           "# TYPE postfix_queue_oldest_message_age_seconds gauge",
           "postfix_queue_oldest_message_age_seconds \([$now - ($queue | map(.arrival_time) | min // $now), 0] | max)",
           "# TYPE postfix_queue_last_success_timestamp_seconds gauge",
           "postfix_queue_last_success_timestamp_seconds \($now)"] | .[]
        else error("Invalid Postfix queue listing") end
      ' > "$output" 2>/dev/null; then
        echo "Postfix queue metrics collection failed" >&2
        exit 1
      fi
      chmod 0644 "$output"
      mv -f -- "$output" "${metricsDir}/postfix-queue.prom"
    '';
  };
in
{
  services.prometheus.exporters.node.extraFlags = [ "--collector.textfile.directory=${metricsDir}" ];

  systemd.services.postfix-queue-metrics = {
    description = "Collect aggregate Postfix queue metrics";
    after = [ "postfix.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${collect}/bin/collect-postfix-queue-metrics";
      StateDirectory = "postfix-queue-metrics";
      StateDirectoryMode = "0755";
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      TimeoutStartSec = "20s";
    };
  };

  systemd.timers.postfix-queue-metrics = {
    description = "Collect Postfix queue metrics every minute";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
    };
  };

  # These rules show up in Prometheus. Notification routing is separate.
  services.prometheus.rules = [ ''
    groups:
      - name: postfix-queue
        rules:
          - alert: PostfixQueueMetricsStale
            expr: |
              (time() - postfix_queue_last_success_timestamp_seconds{job="node",instance="localhost:9100"} > 300)
              or absent(postfix_queue_last_success_timestamp_seconds{job="node",instance="localhost:9100"})
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "Postfix queue metrics are missing or stale on jam"
          - alert: PostfixQueueOldMessage
            expr: |
              postfix_queue_oldest_message_age_seconds{job="node",instance="localhost:9100"} > 3600
              and (time() - postfix_queue_last_success_timestamp_seconds < 300)
            for: 15m
            labels:
              severity: warning
            annotations:
              summary: "A message has been queued for over an hour on jam"
  '' ];
}
