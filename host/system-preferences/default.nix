{ pkgs, ... }:
{

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [
      "FiraCode"
      "Hack"
      "Inconsolata"
      "Iosevka"
      "JetBrainsMono"
      "Monoid"
      "ProFont"
      "ProggyClean"
    ]; })
    cozette
  ];

  security.pam.enableSudoTouchIdAuth = true;

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      alf = {
        globalstate = 2;
        loggingenabled = 0;
        stealthenabled = 1;
      };


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
        #_HIHideMenuBar = true;
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
