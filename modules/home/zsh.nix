{
  config,
  pkgs,
  lib,
  ...
}: {
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
      initContent = lib.optionalString pkgs.stdenv.isDarwin ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
      profileExtra = lib.optionalString pkgs.stdenv.isDarwin ''
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
