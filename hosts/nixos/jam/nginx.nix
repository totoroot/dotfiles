{ domain, autheliaHost, thymITAutheliaHost }:
{ config, lib, ... }:
let
  autheliaBackend = "http://127.0.0.1:9091";
  autheliaAuthSnippet = host: ''
    auth_request /authelia;
    auth_request_set $user $upstream_http_remote_user;
    auth_request_set $groups $upstream_http_remote_groups;
    auth_request_set $name $upstream_http_remote_name;
    auth_request_set $email $upstream_http_remote_email;
    proxy_set_header Remote-User $user;
    proxy_set_header Remote-Groups $groups;
    proxy_set_header Remote-Name $name;
    proxy_set_header Remote-Email $email;
    error_page 401 =302 https://${host}/?rd=$scheme://$http_host$request_uri;
  '';
  autheliaLocationSnippet = ''
    internal;
    proxy_pass ${autheliaBackend}/api/authz/auth-request;
    proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
    proxy_set_header X-Original-Method $request_method;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header Content-Length "";
    proxy_pass_request_body off;
  '';
in
{
  # Protect selected dashboards behind Authelia forward-auth.
  services.nginx.virtualHosts = {
    "geburtstags.${domain}".locations = {
      "/api/rsvp" = {
        proxyPass = "http://127.0.0.1:${toString config.modules.services.email-backend.port}/send/rsvp";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };

      "/api/rsvp-confirmation" = {
        proxyPass = "http://127.0.0.1:${toString config.modules.services.email-backend.port}/send/rsvp-confirmation";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };

    "grueneis-psychologie.at".locations."/api/contact" = {
      proxyPass = "http://127.0.0.1:${toString config.modules.services.email-backend.port}/send/kontakt";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };

    "thym.it".locations."/api/contact" = {
      proxyPass = "http://127.0.0.1:${toString config.modules.services.email-backend.port}/send/thymit-contact";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };

    "thym.it".locations."/api/contact-confirmation" = {
      proxyPass = "http://127.0.0.1:${toString config.modules.services.email-backend.port}/send/thymit-contact-confirmation";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };

    "delivery.thym.it" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString config.modules.services.windshift.port}";
          proxyWebsockets = true;
          extraConfig = autheliaAuthSnippet thymITAutheliaHost;
        };
        "/authelia".extraConfig = autheliaLocationSnippet;
      };
    };

    "ausm-keller.thym.it" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/ausm-keller.at";
      locations = {
        "/".extraConfig = autheliaAuthSnippet thymITAutheliaHost;
        "/authelia".extraConfig = autheliaLocationSnippet;
      };
    };

    "ausm-keller.at" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/ausm-keller.at";
      serverAliases = [ "www.ausm-keller.at" ];
      extraConfig = ''
        error_page 404 /404.html;
      '';
      locations = {
        "= /".extraConfig = ''
          try_files /index.html =404;
        '';
        "= /404.html".extraConfig = ''
          internal;
        '';
        "= /index.html".extraConfig = ''
          return 301 /$is_args$args;
        '';
        "~ ^/(.+)\\.html$".extraConfig = ''
          rewrite ^/(.+)\\.html$ /$1 permanent;
        '';
        "/".extraConfig = ''
          try_files $uri $uri.html =404;
        '';
      };
    };

    # API-only hostname: Windshift authenticates requests with scoped bearer
    # tokens. Do not add Authelia here; the REST API rejects session cookies.
    "api.delivery.thym.it" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/".extraConfig = "return 404;";
        "/rest/api/v1/" = {
          proxyPass = "http://127.0.0.1:${toString config.modules.services.windshift.port}";
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie "";
            proxy_set_header Remote-User "";
            proxy_set_header Remote-Groups "";
            proxy_set_header Remote-Name "";
            proxy_set_header Remote-Email "";
          '';
        };
      };
    };

    "status.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet autheliaHost;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "grafana.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet autheliaHost;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "prometheus.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet autheliaHost;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "loki.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet autheliaHost;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "zugriffs.${domain}".locations = {
      # Keep GoAccess's cache directives before the host's auth snippet.
      "/".extraConfig = lib.mkAfter (autheliaAuthSnippet autheliaHost);
      "/ws".extraConfig = autheliaAuthSnippet autheliaHost;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "website.${domain}" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://${config.services.changedetection-io.listenAddress}:${toString config.services.changedetection-io.port}";
          proxyWebsockets = true;
          extraConfig = autheliaAuthSnippet autheliaHost;
        };
        "/authelia".extraConfig = autheliaLocationSnippet;
      };
    };

    "ntfy.thym.it".locations = {
      "/".extraConfig = autheliaAuthSnippet thymITAutheliaHost;
      "/authelia".extraConfig = autheliaLocationSnippet;
      # Native ntfy clients authenticate against ntfy's own per-topic ACLs.
      # Bypass Authelia only for the explicitly managed client topics.
      "~ ^/((jam-backups|uptime-alerts|change-alerts)(,(jam-backups|uptime-alerts|change-alerts))*)(/(auth|json|sse|ws|raw))?$" = {
        proxyPass = "http://localhost:6780";
        proxyWebsockets = true;
        extraConfig = "auth_request off;";
      };
    };

    "festplatten.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet autheliaHost;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "anzeigen.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet autheliaHost;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "papier.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet autheliaHost;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "besucherinnen.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet autheliaHost;
      "/authelia".extraConfig = autheliaLocationSnippet;
      "/js/" = {
        proxyPass = "http://127.0.0.1:7129";
        proxyWebsockets = true;
        extraConfig = ''
          auth_request off;
        '';
      };
      "= /api/event" = {
        proxyPass = "http://127.0.0.1:7129";
        proxyWebsockets = true;
        extraConfig = ''
          auth_request off;
        '';
      };
    };
  };
}
