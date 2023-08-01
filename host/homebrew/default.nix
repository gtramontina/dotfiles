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
    ];

    brews = [
      "docker"
      "docker-compose"
      "docker-credential-helper"
    ];

    casks = [
      "arc"
      "1password"
      "appcleaner"
      "blockblock"
      "brave-browser"
      "goland"
      "kap"
      "knockknock"
      "visual-studio-code"
      # "little-snitch" # downloaded manually -- sonoma not yet supported
      "micro-snitch"
      "monodraw"
      "orbstack"
      # "orion"
      "proton-drive"
      "protonvpn"
      "raycast"
      "reikey"
      "shottr"
      "signal"
      "the-unarchiver"
      "tuple"
      "utm"
      "zed"
      "whatsapp"
    ];

    masApps = {
      # Dato = 1470584107;
      GoProPlayer_ReelSteady = 1460836908;
      XCode = 497799835;
      Cleaner_For_XCode = 1296084683;
    };
  };
}
