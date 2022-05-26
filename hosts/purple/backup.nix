{ pkgs, ... }:
{
  services.syncthing = {
    # Overrides any devices added or deleted through the WebUI
    overrideDevices = false;
    # Overrides any folders added or deleted through the WebUI
    overrideFolders = false;

    devices = {
      purple.id = "C6E5H63-KPO3NWZ-WMIY4TN-PHQGLXQ-ZLQC2WL-YOX3BG2-BIFJ6RV-O2QKWAU";
      violet.id = "ESP4NJ3-KP3QB7K-TN6G6S2-7PLQNB5-7CFQGVQ-DRICFJ2-PHGKTAO-GDHOGAR";
      lilac.id = "4K4Q7HM-KLYVORI-QPVOZKJ-7Y27FSE-DU4M4D6-5PU6HAB-ZLHJJK4-6AQVNAS";
      phone.id = "CHUU3Y7-XQ2MHGU-XYLHRQW-CZ6QW6C-WAG6R4A-XDW2Z3W-XBT7BLK-GE25KQO";
    };

    folders = {
      "phone-camera" = {
        path = "/home/mathym/sync/phone/camera";
        devices = "phone";
      };
      "phone-downloads" = {
        path = "/home/mathym/sync/phone/camera";
        devices = "phone";
      };
    };
  };


}
