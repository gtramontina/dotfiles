{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    (
      if stdenv.hostPlatform.isDarwin
      then pinentry_mac
      else pinentry-qt
    )
  ];

  home.file.".gnupg/gpg-agent.conf" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    text = "pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac\n";
  };
}
