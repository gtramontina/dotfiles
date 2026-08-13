{
  config,
  pkgs,
  ...
}: {
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt;
  };
}
