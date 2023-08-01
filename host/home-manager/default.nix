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
    ./wezterm.nix
  ];

  home = {
    stateVersion = "23.05";

    packages = with pkgs; [
      # colima # installing via brew to get latest
      btop
      cloc
      coreutils
      crystal
      shards # crystal dependency manager
      ctop
      diskonaut
      elinks
      fd
      gh
      glow
      htop
      nushell
      ripgrep
      tree
      xplr
      python310Packages.pipx

      # Work
      aws-vault
      awscli2
      go
      graphviz
      jdk11
      jq
      nodejs
      rustup
      yarn
    ];
  };

  programs.helix = {
    enable = true;
  };
}
