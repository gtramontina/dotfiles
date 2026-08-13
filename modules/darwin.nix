{pkgs, ...}: {
  nix = {
    enable = false;
    settings.experimental-features = "nix-command flakes";
  };

  security = {
    pam.services.sudo_local.touchIdAuth = true;
  };

  fonts.packages = [
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.go-mono
    pkgs.nerd-fonts.monaspace
    pkgs.departure-mono
  ];

  users.users.gtramontina = {
    home = "/Users/gtramontina";
    uid = 501;
    description = "Guilherme J. Tramontina";
  };

  networking = {
    applicationFirewall = {
      enable = true;
      enableStealthMode = true;
      blockAllIncoming = true;
    };
  };

  system = {
    stateVersion = 6;
    primaryUser = "gtramontina";

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        CreateDesktop = false;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.5;
        mru-spaces = false;
        orientation = "left";
        show-process-indicators = true;
        show-recents = false;
        showhidden = false;
        static-only = false;
        tilesize = 30;
      };

      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };

      NSGlobalDomain = {
        _HIHideMenuBar = true;
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 10;
        KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      SoftwareUpdate = {
        AutomaticallyInstallMacOSUpdates = true;
      };
    };
  };
}
