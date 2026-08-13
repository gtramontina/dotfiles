{
  config,
  lib,
  pkgs,
  profile ? "personal",
  ...
}: {
  homebrew = {
    enable = true;

    onActivation = {
      upgrade = true;
      autoUpdate = true;
      cleanup = "zap";
      extraFlags = ["--force-cleanup"];
    };

    extraConfig = ''
      cask_args require_sha: true
      cask_args appdir: "${config.system.primaryUserHome}/Applications"
    '';

    taps = [];

    brews = [
      "gemini-cli"
      "mole"
      "herdr"
    ];

    casks =
      [
        "1password"
        "8bitdo-ultimate-software-v2"
        "appcleaner"
        "betterdisplay"
        "brave-browser"
        "handy"
        "little-snitch"
        "micro-snitch"
        "monodraw"
        "orbstack"
        "protonvpn"
        "raycast"
        "shottr"
        "the-unarchiver"
        "zed@preview"
        "ghostty"
        "signal"
        "tailscale-app"
        "stremio"
      ]
      ++ lib.optionals (profile == "work") [
        "notion-calendar"
        "slack"
        "licecap"
        "tuple"
        "pop-app"
      ];

    masApps = {};
  };
}
