{ config, pkgs, ... }:
{

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 14;
        normal = {
          family = "Berkeley Mono";
          style = "Regular";
        };
        bold = {
          family = "Berkeley Mono";
          style = "Bold";
        };
        italic = {
          family = "Berkeley Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "Berkeley Mono";
          style = "Bold Italic";
        };
      };

      window = {
        padding = {
          x = 0;
          y = 0;
        };
      };
    };
  };

}
