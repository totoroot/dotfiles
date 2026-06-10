{ pkgs, inputs, lib, ... }:
let
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in
{
  modules.home.zsh.rcInit = lib.mkAfter ''
    # Copy the most recent Codex session reply to the clipboard.
    vibe(){ tail -n2 $(ls -t ~/.codex/sessions/*/*/*/*.jsonl | head -n1) | jq -r 'select(.payload.content) |.payload.content[0].text' | kitten clipboard; }
  '';

  modules.home.unfreePackages = {
    enable = true;
    packageNames = [
      "orbstack"
    ];
  };

  home.packages = with pkgs; [
    black
    cheat
    curl
    exiftool
    findutils
    glow
    htop
    jq
    joshuto
    lf
    clolcat
    mpv
    nixpkgs-review
    podman-compose
    pdfcpu
    tree
    unar
    unzip
    wget
    yamllint
    yq-go
    helix
    shellcheck
    gdk
    geany
    go
    ydiff
    cachix
    niv
    gnused
    gnutar
    gnutls
    gawk
    maccy
    rectangle
    itsycal
    karabiner-elements
    alt-tab-macos
    autoraise
    python313
    python313Packages.virtualenv
    python313Packages.pip
    python313Packages.pip-tools
    python313Packages.pylint
    python313Packages.beautifulsoup4
    gotop
    orbstack
    vscodium
    inputs.rcat.packages.${pkgs.system}.default
    inputs.nixpkgs-handy.legacyPackages.${pkgs.system}.handy
  ];
}
