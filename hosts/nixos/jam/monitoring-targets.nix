let
  minute = "1m";
in
[
  # Public domains
  {
    name = "thym.at";
    group = "domains";
    url = "https://thym.at";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "matthias.thym.at";
    group = "domains";
    url = "https://matthias.thym.at";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "blog.thym.at";
    group = "domains";
    url = "https://blog.thym.at";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "nixos.at";
    group = "domains";
    url = "https://nixos.at";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "theaterschaffen.de";
    group = "domains";
    url = "https://theaterschaffen.de";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "womanma.de";
    group = "domains";
    url = "https://womanma.de";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "blob.thym.it";
    group = "domains";
    url = "https://blob.thym.it";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "cambodianyouthsupport.com";
    group = "domains";
    url = "https://cambodianyouthsupport.com";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "thym.it";
    group = "domains";
    url = "https://thym.it";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "grueneis-psychologie.at";
    group = "domains";
    url = "https://grueneis-psychologie.at";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "überwachungsbehör.de";
    group = "domains";
    url = "https://überwachungsbehör.de";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "kuh.überwachungsbehör.de";
    group = "domains";
    url = "https://kuh.xn--berwachungsbehr-mtb1g.de";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }

  # Public HTTPS service checks
  {
    name = "homepage";
    group = "services";
    url = "https://überwachungsbehör.de";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "ntfy";
    group = "services";
    url = "https://benachrichtigungs.xn--berwachungsbehr-mtb1g.de";
    interval = minute;
    conditions = [ "[STATUS] >= 200 && [STATUS] < 400" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "vaultwarden";
    group = "services";
    url = "https://passwort.xn--berwachungsbehr-mtb1g.de/alive";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "nextcloud";
    group = "services";
    url = "https://cloud.thym.at/status.php";
    interval = minute;
    conditions = [ "[STATUS] == 200" "[BODY].installed == true" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }
  {
    name = "roundcube-webmail";
    group = "services";
    url = "https://mail.thym.it";
    interval = minute;
    conditions = [ "[STATUS] >= 200 && [STATUS] < 400" ];
    blackbox = true;
    certificate = true;
    gatus = true;
  }

  # Internal/non-HTTPS checks (Gatus only)
  {
    name = "grafana";
    group = "services";
    url = "http://127.0.0.1:3000/api/health";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    gatus = true;
  }
  {
    name = "prometheus";
    group = "services";
    url = "http://127.0.0.1:9090/-/healthy";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    gatus = true;
  }
  {
    name = "loki";
    group = "services";
    url = "http://127.0.0.1:3100/ready";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    gatus = true;
  }
  {
    name = "goaccess";
    group = "services";
    url = "http://127.0.0.1:7890";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    gatus = true;
  }
  {
    name = "adguard";
    group = "services";
    url = "http://100.64.0.3:6060/login.html";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    gatus = true;
  }
  {
    name = "plausible";
    group = "services";
    url = "http://127.0.0.1:7129/api/health";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    gatus = true;
  }
  {
    name = "medien";
    group = "services";
    url = "http://100.64.0.3:8096/health";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    gatus = true;
  }
  {
    name = "wunschliste";
    group = "services";
    url = "http://100.64.0.3:5055/api/v1/status";
    interval = minute;
    conditions = [ "[STATUS] == 200" ];
    gatus = true;
  }

  # Mail protocol checks (Gatus only)
  {
    name = "smtp";
    group = "mail";
    url = "tcp://127.0.0.1:25";
    interval = minute;
    conditions = [ "[CONNECTED] == true" ];
    gatus = true;
  }
  {
    name = "submission";
    group = "mail";
    url = "tcp://127.0.0.1:587";
    interval = minute;
    conditions = [ "[CONNECTED] == true" ];
    gatus = true;
  }
  {
    name = "imap";
    group = "mail";
    url = "tcp://127.0.0.1:993";
    interval = minute;
    conditions = [ "[CONNECTED] == true" ];
    gatus = true;
  }
]
