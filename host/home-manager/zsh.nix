{ config, pkgs, ... }:

let

  aliases = {
    l = "exa --all --long --header --git --icons --classify";
    g = "git";
    vim = "XDG_CONFIG_HOME=~/.astronvim nvim";

    # dotfiles
    dot-rebuild = "darwin-rebuild switch";
    dot-update = "nix-channel --update && sudo nix-channel --update && dot-rebuild && sudo softwareupdate -i -a --restart";
    dot-edit = "eval \"$EDITOR ${builtins.toString ./../..}\"";
    dot-cleanup = "nix-collect-garbage -d && sudo nix-collect-garbage -d && brew cleanup";

    # WORK
    v = "aws-vault exec --debug --duration=1h";
    ci = "(git pull --rebase origin master && make test.all lint && git push origin master && osascript -e 'display notification \"✅ Succeeded!\" with title \"Push\" sound name \"Submarine\"') || osascript -e 'display notification \"❌ Failed!\" with title \"Push\" sound name \"Submarine\"'";
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
      enableAutosuggestions = true;
      autocd = true;
      sessionVariables = environmentVariables;
      shellAliases = aliases;
      plugins = [
        {
          name = "base16-shell";
          file = "base16-shell.plugin.zsh";
          src = builtins.fetchGit {
            url = "https://github.com/chriskempson/base16-shell";
            rev = "588691ba71b47e75793ed9edfcfaa058326a6f41";
          };
        }
      ];
      initExtra = ''
        # Set PATH, MANPATH, etc., for Homebrew.
        eval "$(/opt/homebrew/bin/brew shellenv)"

        PATH=$PATH:$HOME/.local/bin

        # Configure links for docker plugins
        [[ ! -d "$HOME/.docker/cli-plugins" ]] && \
          mkdir -p "$HOME/.docker/cli-plugins"
        [[ ! "$(readlink "$HOME/.docker/cli-plugins/docker-compose")" -ef /opt/homebrew/opt/docker-compose/bin/docker-compose ]] && \
          ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose "$HOME/.docker/cli-plugins/docker-compose"

        # Load pyenv
        export PYENV_ROOT="$HOME/.pyenv"
        command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
      '';
    };

    starship = {
      enable = true;
    };

    exa = {
      enable = true;
      enableAliases = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };

}
