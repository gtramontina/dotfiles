{ config, lib, pkgs, ... }:
{

  homebrew = {
    enable = true;

    onActivation = {
      upgrade = true;
      autoUpdate = true;
      cleanup = "zap";
    };

    extraConfig = ''
      cask_args require_sha: true
      cask_args appdir: "${builtins.getEnv "HOME"}/Applications"
    '';

    taps = [
      "homebrew/cask"
    ];

    brews = [
      "docker"
      "docker-compose"
      "docker-credential-helper"
    ];

    casks = [
      "appcleaner"
      "brave-browser"
      "little-snitch"
      "micro-snitch"
      "monodraw"
      "protonvpn"
      "raycast"
      "reikey"
      "signal"
      "spotify"

      # Work
      "cron"
      "goland"
      "tuple"
      "zoom"
    ];

    masApps = {
      Dato = 1470584107;
    };
  };

}
