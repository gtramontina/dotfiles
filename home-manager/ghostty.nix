{
  config,
  pkgs,
  ...
}: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    # Ghostty does not yet build on macOS, but a pre-built binary can be installed via Homebrew.
    # And this is what I'm doing: installing with Homebrew.
    package = null;

    settings = {
      background-opacity = 0.9;
      background-blur = true;
      confirm-close-surface = false;
      font-family = "Berkeley Mono";
      font-size = 12;
      theme = "dark:Catppuccin Frappe,light:Catppuccin Latte";

      cursor-style = "block";
      shell-integration-features = "no-cursor";
      cursor-style-blink = false;
      link-url = true;
      window-inherit-working-directory = true;
      window-inherit-font-size = true;
      window-theme = "system";
      clipboard-trim-trailing-spaces = true;

      mouse-hide-while-typing = true;
      macos-titlebar-proxy-icon = "hidden";
      macos-icon = "custom-style";
      macos-icon-frame = "beige";
      macos-icon-ghost-color = "D25C00";
      macos-icon-screen-color = "000000";
    };
  };
}
