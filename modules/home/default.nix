{
  config,
  lib,
  pkgs,
  profile ? "personal",
  ...
}: {
  home = {
    stateVersion = "23.11";

    sessionVariables = {
      EDITOR = "vim";
      HOMEBREW_NO_ANALYTICS = 1;
      HOMEBREW_NO_ENV_HINTS = 1;
    };

    packages =
      (with pkgs; [
        devbox
        gh
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
