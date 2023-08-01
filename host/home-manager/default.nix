{ config, pkgs, ... }:
{

  imports = [
    ./direnv.nix
    ./git.nix
    ./neovim.nix
    ./newsboat.nix
    # ./tmux.nix
    ./zsh.nix
    ./wezterm.nix
    #./vscode.nix # installed with brew
  ];

  home = {
    stateVersion = "23.11";

    packages = with pkgs; [
      devbox
      gnupg
      nodejs_21
      ripgrep
    ];
  };

  programs.helix = {
    enable = true;
  };
}
