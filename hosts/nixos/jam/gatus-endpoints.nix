[
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
