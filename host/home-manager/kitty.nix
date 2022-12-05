{ config, pkgs, ... }:
{

  programs.kitty = {
    enable = true;
    font.name = "Berkeley Mono";
    font.size = 12;
  };

}
