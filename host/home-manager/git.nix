{ config, pkgs, ... }:
{

  home = {
    stateVersion = "22.05";

    packages = with pkgs; [
      git-extras
    ];
  };

  programs.git = {
    enable = true;
    userName = "Guilherme J. Tramontina";
    userEmail = "guilherme.tramontina@gmail.com";
    signing = {
      signByDefault = true;
      key = "F38C7CF9";
    };
    aliases = {
      lg = "log --graph --date=format:'%Y-%m-%d %H:%I' --pretty=format:'%C(bold yellow)%h%C(reset) %C(green)%ad%C(reset) %C(blue)%<(18,trunc)%aE%C(reset) %C(reset)%s%C(reset)%C(bold red)%d%C(reset)'";
      st = "status --short";
      ci = "commit --verbose";
      co = "checkout";
      reb = "!git pull --rebase origin $(git branch | grep '*' | cut -d ' ' -f2)";
      unstage = "reset HEAD --";
    };
    extraConfig = {
      core.editor = "vim";
      diff.colorMoved = "default";
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      rebase.autosquash = true;
      rebase.autostash = true;
    };
  };

}
