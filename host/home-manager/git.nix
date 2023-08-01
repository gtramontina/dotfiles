{ config, pkgs, ... }:
{

  home = {
    packages = with pkgs; [
      git-extras
      delta
    ];
  };

  programs.git = {
    enable = true;
    userName = "Guilherme J. Tramontina";
    userEmail = "guilherme.tramontina@gmail.com";
    signing = {
      signByDefault = true;
      key = "04D8737E49D558DE";
    };
    aliases = {
      lg = "log --graph --date=format:'%Y-%m-%d %H:%I' --pretty=format:'%C(bold yellow)%h%C(reset) %C(green)%ad%C(reset) %C(blue)%<(18,trunc)%aE%C(reset) %C(reset)%s%C(reset)%C(bold red)%d%C(reset)'";
      st = "status --short";
      ci = "commit --verbose";
      co = "checkout";
      ap = "!git add --intent-to-add . && git add --patch";
      reb = "!git pull --rebase origin $(git branch | grep '*' | cut -d ' ' -f2)";
      unstage = "reset HEAD --";
      pretty-diff = "!delta $(defaults read -g AppleInterfaceStyle &>/dev/null || echo --light)";
    };
    extraConfig = {
      core.editor = "nvim";
      diff.colorMoved = "default";
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      rebase.autosquash = true;
      rebase.autostash = true;

      core.pager = "git pretty-diff";
	    delta.features = "side-by-side defaults unobtrusive-line-numbers decorations hyperlinks";
      delta.true-color = "always";
      interactive.diffFilter = "git pretty-diff --color-only --features=interactive";
    };
  };
}
