{
  config,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      git-extras
    ];
  };

  programs.git = {
    enable = true;

    settings = {
      alias = {
        lg = "log --graph --date=format:'%Y-%m-%d %H:%I' --pretty=format:'%C(bold yellow)%h%C(reset) %C(green)%ad%C(reset) %C(blue)%<(18,trunc)%aE%C(reset) %C(reset)%s%C(reset)%C(bold red)%d%C(reset)'";
        st = "status --short";
        ci = "commit --verbose";
        co = "checkout";
        ap = "!git add --intent-to-add . && git add --patch";
        reb = "!git pull --rebase origin $(git branch | grep '*' | cut -d ' ' -f2)";
        unstage = "reset HEAD --";
      };

      diff = {
        colorMoved = "default";
      };

      init = {
        defaultBranch = "main";
      };

      merge = {
        conflictstyle = "diff3";
      };

      rebase = {
        autosquash = true;
        autostash = true;
      };

      fetch = {
        prune = true;
      };
    };
  };
}
