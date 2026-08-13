{
  config,
  pkgs,
  ...
}: {
  home = {
    stateVersion = "23.11";
    username = "gtramontina";
    homeDirectory = "/Users/gtramontina";

    sessionVariables = {
      EDITOR = "vim";
      HOMEBREW_NO_ANALYTICS = 1;
      HOMEBREW_NO_ENV_HINTS = 1;
    };

    packages = with pkgs; [
      devbox
      gh
      gnupg
      ripgrep
      ast-grep

      alejandra # .nix "prettier"

      claude-code
      codex
    ];
  };

  imports = [
    ./ghostty.nix
    ./git.nix
    ./gpg.nix
    ./hunk.nix
    # ./vscode.nix
    ./opencode.nix
    ./zsh.nix
    ./zed-editor.nix
  ];
}
