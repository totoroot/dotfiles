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
    url = "http://127.0.0.1:3000/api/health";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "prometheus";
    group = "services";
    url = "http://127.0.0.1:9090/-/healthy";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
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
    url = "http://127.0.0.1:7890";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "adguard";
    group = "services";
    url = "http://100.64.0.3:3300/login.html";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "plausible";
    group = "services";
    url = "http://127.0.0.1:7129/api/health";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }

  {
    name = "medien";
    group = "services";
    url = "http://100.64.0.3:8096/health";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
  }
  {
    name = "wunschliste";
    group = "services";
    url = "http://100.64.0.3:5055/api/v1/status";
    interval = "1m";
    conditions = [ "[STATUS] == 200" ];
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
