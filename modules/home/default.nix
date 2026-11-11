{
  config,
  identity,
  lib,
  pkgs,
  profile ? "personal",
  ...
}: {
  # Home Manager's generated options manual triggers a context warning on Nix 2.33.
  manual.manpages.enable = false;

  home = {
    stateVersion = "23.11";

    sessionVariables = {
      DISABLE_TELEMETRY = 1;
      DO_NOT_TRACK = 1;
      EDITOR = "vim";
      DOTFILES_DIR = identity.dotfilesDirectory;
      HOMEBREW_NO_ANALYTICS = 1;
      HOMEBREW_NO_ENV_HINTS = 1;
      OTEL_SDK_DISABLED = "true";
    };

    packages =
      (with pkgs; [
        devbox
        gh
        gnumake
        gnupg
        ripgrep

        alejandra # .nix "prettier"
      ])
      ++ lib.optionals (profile == "work") (with pkgs; [
        # work-only packages
        ast-grep
        claude-code
        codex
      ]);
  };

  imports =
    [
      ./ghostty.nix
      ./git.nix
      ./gpg.nix
      ./hunk.nix
      # ./vscode.nix
      ./opencode.nix
      ./zsh.nix
      ./zed-editor.nix
    ]
    ++ lib.optionals (profile == "work") [
      # work-only modules
    ];
}
