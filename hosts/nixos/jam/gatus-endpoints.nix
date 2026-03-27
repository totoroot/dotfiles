[
  # Domains
  {
    name = "thym.at";
    group = "domains";
    url = "https://thym.at";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "matthias.thym.at";
    group = "domains";
    url = "https://matthias.thym.at";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "theaterschaffen.de";
    group = "domains";
    url = "https://theaterschaffen.de";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "womanma.de";
    group = "domains";
    url = "https://womanma.de";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "cambodianyouthsupport.com";
    group = "domains";
    url = "https://cambodianyouthsupport.com";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "thym.it";
    group = "domains";
    url = "https://thym.it";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "grueneis-psychologie.at";
    group = "domains";
    url = "https://grueneis-psychologie.at";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "überwachungsbehör.de";
    group = "domains";
    url = "https://überwachungsbehör.de";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }

  # Jam services
  {
    name = "homepage";
    group = "services";
    url = "https://überwachungsbehör.de";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "ntfy";
    group = "services";
    url = "https://benachrichtigungs.xn--berwachungsbehr-mtb1g.de";
    interval = "1m";
    conditions = [ "[STATUS] >= 200 && [STATUS] < 400" ];
  }
  {
    name = "vaultwarden";
    group = "services";
    url = "https://passwort.xn--berwachungsbehr-mtb1g.de/alive";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "grafana";
    group = "services";
    url = "https://grafana.xn--berwachungsbehr-mtb1g.de/login";
    interval = "1m";
    conditions = [ "[STATUS] >= 200 && [STATUS] < 400" ];
  }
  {
    name = "prometheus";
    group = "services";
    url = "https://prometheus.xn--berwachungsbehr-mtb1g.de/";
    interval = "1m";
    conditions = [ "[STATUS] == 401" ];
  }
  {
    name = "nextcloud";
    group = "services";
    url = "https://cloud.thym.at/status.php";
    interval = "1m";
    conditions = [
      "[STATUS] == 200"
      "[BODY].installed == true"
    ];
  }
  {
    name = "roundcube-webmail";
    group = "services";
    url = "https://mail.xn--berwachungsbehr-mtb1g.de";
    interval = "1m";
    conditions = [ "[STATUS] >= 200 && [STATUS] < 400" ];
  }
  {
    name = "goaccess";
    group = "services";
    url = "https://zugriffs.xn--berwachungsbehr-mtb1g.de";
    interval = "1m";
    conditions = [ "[STATUS] >= 200 && [STATUS] < 400" ];
  }

  {
    name = "medien";
    group = "services";
    url = "https://medien.xn--berwachungsbehr-mtb1g.de";
    interval = "1m";
    conditions = [ "[STATUS] >= 200 && [STATUS] < 400" ];
  }
  {
    name = "wunschliste";
    group = "services";
    url = "https://wunschliste.xn--berwachungsbehr-mtb1g.de";
    interval = "1m";
    conditions = [ "[STATUS] >= 200 && [STATUS] < 400" ];
  }

  # Mail protocol checks
  {
    name = "smtp";
    group = "mail";
    url = "tcp://127.0.0.1:25";
    interval = "1m";
    conditions = [ "[CONNECTED] == true" ];
  }
  {
    name = "submission";
    group = "mail";
    url = "tcp://127.0.0.1:587";
    interval = "1m";
    conditions = [ "[CONNECTED] == true" ];
  }
  {
    name = "imap";
    group = "mail";
    url = "tcp://127.0.0.1:993";
    interval = "1m";
    conditions = [ "[CONNECTED] == true" ];
  }
]
