{
  config,
  pkgs,
  ...
}: {
  # Home-manager now manages ~/.zprofile unconditionally (since the 2026-06-02
  # "load session vars from zprofile for login shells" change). The existing
  # file was created by OrbStack, so let home-manager take it over. The OrbStack
  # init is preserved via programs.zsh.profileExtra below.
  #
  # NOTE: the zsh module keys this file as "./.zprofile" (dotDirRel == "."), and
  # checkLinkTargets globs forced paths as "$HOME/./.zprofile*", which never
  # matches the real "$HOME/.zprofile" — so force alone is silently ignored.
  # Overriding target to ".zprofile" makes the glob match and force take effect.
  home.file."./.zprofile" = {
    force = true;
    target = ".zprofile";
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting = {enable = true;};
      autosuggestion = {enable = true;};
      autocd = true;
      shellAliases = {
        l = "eza --all --long --header --links --git --git-repos --icons --classify --hyperlink";
        g = "git";
      };
      initContent = ''
        # Homebrew
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
      profileExtra = ''
        # Added by OrbStack: command-line tools and integration
        source ~/.orbstack/shell/init.zsh 2>/dev/null || :
      '';
    };

    eza = {
      enable = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        custom = {
          direnv = {
            format = "[«direnv»]($style) ";
            style = "fg:yellow dimmed";
            when = "printenv DIRENV_FILE";
          };
        };
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
