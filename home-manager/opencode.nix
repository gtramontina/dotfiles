{
  config,
  pkgs,
  ...
}: {
  programs.opencode = {
    enable = true;

    settings = {
      plugin = [
        # "opencode-gemini-auth@latest"
      ];
    };
  };
}
