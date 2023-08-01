{ config, pkgs, ... }:

let
  aliases = {
    l = "eza --all --long --header --links --git --git-repos --icons --classify --hyperlink";
    g = "git";
    vim = "nvim";
    vi = "nvim";

    # dotfiles
    dot-rebuild = "darwin-rebuild switch";
    dot-update = "nix-channel --update && sudo nix-channel --update && dot-rebuild && sudo softwareupdate -i -a --restart";
    dot-edit = "eval \"$EDITOR ${builtins.toString ./../..}\"";
    dot-cleanup = "sudo nix-collect-garbage -d && nix-collect-garbage -d && brew cleanup";
    dot-upgrade = "sudo rm -rf /etc/shells && dot-update && dot-cleanup";
  };

  environmentVariables = {
    EDITOR = "vim";
    HOMEBREW_NO_ANALYTICS = 1;
  };

in {

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting = { enable = true; };
      autosuggestion = { enable = true; };
      autocd = true;
      sessionVariables = environmentVariables;
      shellAliases = aliases;
      initExtra = ''
        # Homebrew
        eval "$(/opt/homebrew/bin/brew shellenv)"

        PATH=$PATH:$HOME/.local/bin

        # Docker Plugins
        [[ ! -d "$HOME/.docker/cli-plugins" ]] && \
          mkdir -p "$HOME/.docker/cli-plugins"
        [[ ! "$(readlink "$HOME/.docker/cli-plugins/docker-compose")" -ef /opt/homebrew/opt/docker-compose/bin/docker-compose ]] && \
          ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose "$HOME/.docker/cli-plugins/docker-compose"
      '';
    };

    starship = {
      enable = true;
      settings = {
        add_newline = false;
        custom = {
          direnv = {
            format = "[\\[direnv\\]]($style) ";
            style = "fg:yellow dimmed";
            when = "printenv DIRENV_FILE";
          };
        };
      };
    };

    eza = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };

}
