{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    pinentry_mac
  ];

  # home-manager's services.gpg-agent module is Linux-only (systemd), so on
  # darwin we manage gpg-agent.conf directly. Without a pinentry program
  # gpg-agent can't prompt for the passphrase and signing fails with
  # "gpg: signing failed: No pinentry". pinentry-mac gives a native macOS
  # dialog (and can save the passphrase to the Keychain).
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
  '';
}
