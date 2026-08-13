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
        "dot:build" = "make -C \"$DOTFILES_DIR\" build";
        "dot:check" = "make -C \"$DOTFILES_DIR\" check";
        "dot:clean" = "make -C \"$DOTFILES_DIR\" clean";
        "dot:edit" = "$EDITOR \"$DOTFILES_DIR\"";
        "dot:fmt" = "make -C \"$DOTFILES_DIR\" fmt";
        "dot:help" = "make -C \"$DOTFILES_DIR\" help";
        "dot:nix-upgrade" = "make -C \"$DOTFILES_DIR\" nix-upgrade";
        "dot:sync" = "\"$DOTFILES_DIR/scripts/sync\"";
        "dot:switch" = "make -C \"$DOTFILES_DIR\" switch";
        "dot:test" = "make -C \"$DOTFILES_DIR\" test";
        "dot:update" = "\"$DOTFILES_DIR/scripts/update\"";
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
