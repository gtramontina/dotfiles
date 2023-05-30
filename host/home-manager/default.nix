{ config, pkgs, ... }:
{

  imports = [
    ./alacritty.nix
    ./git.nix
    ./kitty.nix
    ./neovim.nix
    ./newsboat.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home = {
    stateVersion = "23.05";

    packages = with pkgs; [
      aws-vault
      awscli2
      colima
      go_1_19
      htop
      jq
      nodejs
      yarn
    ];
  };

}
