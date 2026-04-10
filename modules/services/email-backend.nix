{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.email-backend;
  configFormat = pkgs.formats.json { };

  appConfig = {
    bindHost = cfg.bindHost;
    port = cfg.port;
    sender = cfg.sender;
    allowedOrigins = cfg.allowedOrigins;
    smtp = {
      host = cfg.smtp.host;
      port = cfg.smtp.port;
      starttls = cfg.smtp.starttls;
      username = cfg.smtp.username;
      passwordFile = cfg.smtp.passwordFile;
    };
    routes = mapAttrs (_name: routeCfg: {
      recipient = routeCfg.recipient;
      subject = routeCfg.subject;
      requiredFields = routeCfg.requiredFields;
    }) cfg.routes;
  };

  configFile = configFormat.generate "email-backend-config.json" appConfig;

  appScript = pkgs.writeText "email-backend.py" ''
    import json
    import smtplib
    from email.message import EmailMessage
    from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
    from pathlib import Path
    from urllib.parse import urlparse

    CONFIG = json.loads(Path("${configFile}").read_text())

    def as_json(handler, status, payload):
      body = json.dumps(payload).encode("utf-8")
      handler.send_response(status)
      origin = handler.headers.get("Origin")
      allowed = CONFIG.get("allowedOrigins", [])
      if origin and (not allowed or origin in allowed):
        handler.send_header("Access-Control-Allow-Origin", origin)
        handler.send_header("Vary", "Origin")
      handler.send_header("Access-Control-Allow-Headers", "Content-Type")
      handler.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
      handler.send_header("Content-Type", "application/json")
      handler.send_header("Content-Length", str(len(body)))
      handler.end_headers()
      handler.wfile.write(body)

    class Handler(BaseHTTPRequestHandler):
      def do_OPTIONS(self):
        as_json(self, 200, {"ok": True})

      def do_POST(self):
        path = urlparse(self.path).path
        prefix = "/send/"
        if not path.startswith(prefix):
          as_json(self, 404, {"ok": False, "error": "not_found"})
          return

        route = path[len(prefix):]
        route_cfg = CONFIG.get("routes", {}).get(route)
        if not route_cfg:
          as_json(self, 404, {"ok": False, "error": "unknown_route"})
          return

        origin = self.headers.get("Origin")
        allowed = CONFIG.get("allowedOrigins", [])
        if allowed and origin and origin not in allowed:
          as_json(self, 403, {"ok": False, "error": "origin_forbidden"})
          return

        content_length = int(self.headers.get("Content-Length", "0"))
        if content_length <= 0:
          as_json(self, 400, {"ok": False, "error": "missing_body"})
          return

        try:
          payload = json.loads(self.rfile.read(content_length).decode("utf-8"))
        except Exception:
          as_json(self, 400, {"ok": False, "error": "invalid_json"})
          return

        required_fields = route_cfg.get("requiredFields", [])
        missing = [field for field in required_fields if not str(payload.get(field, "")).strip()]
        if missing:
          as_json(self, 400, {"ok": False, "error": "missing_fields", "fields": missing})
          return

        lines = []
        for key in sorted(payload.keys()):
          value = payload.get(key)
          lines.append(f"{key}: {value}")

        message = EmailMessage()
        message["From"] = CONFIG["sender"]
        message["To"] = route_cfg["recipient"]
        message["Subject"] = route_cfg.get("subject") or f"Form submission ({route})"
        message.set_content("\n".join(lines))

        smtp_cfg = CONFIG["smtp"]
        try:
          with smtplib.SMTP(smtp_cfg["host"], int(smtp_cfg["port"]), timeout=15) as smtp:
            smtp.ehlo()
            if smtp_cfg.get("starttls"):
              smtp.starttls()
              smtp.ehlo()
            username = smtp_cfg.get("username")
            password_file = smtp_cfg.get("passwordFile")
            if username:
              if not password_file:
                raise RuntimeError("SMTP username configured but no password file configured")
              password = Path(password_file).read_text().strip()
              smtp.login(username, password)
            smtp.send_message(message)
        except Exception as exc:
          as_json(self, 502, {"ok": False, "error": "smtp_failed", "message": str(exc)})
          return

        as_json(self, 200, {"ok": True})

      def log_message(self, _fmt, *_args):
        return

    if __name__ == "__main__":
      bind_host = CONFIG.get("bindHost", "127.0.0.1")
      port = int(CONFIG.get("port", 8787))
      server = ThreadingHTTPServer((bind_host, port), Handler)
      server.serve_forever()
  '';
in
{
  options.modules.services.email-backend = {
    enable = mkBoolOpt false;
    bindHost = mkOpt' types.str "127.0.0.1" "Bind host for the mail API.";
    port = mkOpt' types.port 8787 "Bind port for the mail API.";
    sender = mkOpt' types.str "admin@xn--berwachungsbehr-mtb1g.de" "Sender email address for outgoing mails.";
    allowedOrigins = mkOpt' (types.listOf types.str) [ ] "Allowed HTTP origins. Empty list disables origin checks.";

    smtp = {
      host = mkOpt' types.str "127.0.0.1" "SMTP host.";
      port = mkOpt' types.port 25 "SMTP port.";
      starttls = mkOpt' types.bool false "Whether to use STARTTLS.";
      username = mkOpt' (types.nullOr types.str) null "Optional SMTP username.";
      passwordFile = mkOpt' (types.nullOr types.path) null "Optional SMTP password file path.";
    };

    routes = mkOpt' (types.attrsOf (types.submodule ({ ... }: {
      options = {
        recipient = mkOpt' types.str "" "Destination email address for this route.";
        subject = mkOpt' types.str "" "Email subject for this route.";
        requiredFields = mkOpt' (types.listOf types.str) [ "name" "email" "message" ] "Required payload keys for this route.";
      };
    }))) { } "Route map for /send/<route> endpoints.";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.routes != { };
        message = "modules.services.email-backend.routes must define at least one route.";
      }
      {
        assertion = all (routeCfg: routeCfg.recipient != "") (attrValues cfg.routes);
        message = "Every email-backend route must configure a non-empty recipient.";
      }
    ];

    systemd.services.email-backend = {
      description = "Simple SMTP mail API backend";
      after = [ "network.target" "postfix.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.python3}/bin/python3 ${appScript}";
        Restart = "on-failure";
        RestartSec = 3;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadOnlyPaths = lib.optional (cfg.smtp.passwordFile != null) cfg.smtp.passwordFile;
        WorkingDirectory = "/";
      };
    };
  };
}
