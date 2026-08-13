{
  config,
  lib,
  pkgs,
  ...
}: {
  homebrew = {
    enable = true;

    onActivation = {
      upgrade = true;
      autoUpdate = true;
      cleanup = "zap";
      # Homebrew Bundle now refuses `brew bundle install --cleanup` without an
      # explicit confirmation flag (errors with "requires --force,
      # --force-cleanup or $HOMEBREW_ASK"). nix-darwin doesn't add it
      # automatically, so force the cleanup non-interactively here.
      extraFlags = ["--force-cleanup"];
    };

    extraConfig = ''
      cask_args require_sha: true
      cask_args appdir: "${builtins.getEnv "HOME"}/Applications"
    '';

    taps = [
    ];

    brews = [
      "gemini-cli"
      "mole"
      # "direnv" # for some reason installing this via zsh isn't working.
      "herdr"
    ];

    casks = [
      "1password"
      "8bitdo-ultimate-software-v2"
      "appcleaner"
      "betterdisplay"
      "brave-browser"
      "handy"
      # "blockblock"
      # "knockknock"
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
      "tailscale"
      "stremio"

      # work
      "notion-calendar"
      "slack"
      "licecap"
      "tuple"
      "pop-app"
    ];

    masApps = {
      # Dato = 1470584107;
      # GoProPlayer_ReelSteady = 1460836908;
      # XCode = 497799835;
      # Cleaner_For_XCode = 1296084683;
    };
  };
}
