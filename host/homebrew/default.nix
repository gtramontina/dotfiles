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
      "jamesjoshuahill/tap"
    ];

    brews = [
      { name = "colima"; args = ["HEAD"]; }
      "docker"
      "docker-compose"
      "docker-credential-helper"
      "pyenv"

      # Work
      "jamesjoshuahill/tap/git-co-author"
      "tfenv"
      "diffutils"
    ];

    casks = [
      # "adobe-acrobat-reader"
      "appcleaner"
      "brave-browser"
      "blockblock"
      "knockknock"
      "little-snitch"
      "micro-snitch"
      "monodraw"
      "popclip"
      "raycast"
      "reikey"
      "shottr"
      "signal"
      "spideroakone"
      "spotify"
      "the-unarchiver"
      "tunnelblick"
      # "vysor"
      # "zed"
      "orbstack"
      "orion"

      # Work
      "cron"
      "jetbrains-toolbox"
      "tuple"
    ];

    masApps = {
      Dato = 1470584107;
    };
  };
}
