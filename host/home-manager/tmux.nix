{ config, pkgs, ... }:
{

  programs = {
    tmux = {
      enable = true;
      baseIndex = 1;
      historyLimit = 10000;
      resizeAmount = 1;
      keyMode = "vi";

      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.battery;
          extraConfig = "set -g @batt_remain_short true";
        }
        {
          plugin = tmuxPlugins.pain-control;
        }
        {
          plugin = tmuxPlugins.prefix-highlight;
          extraConfig = "set -g @prefix_highlight_show_copy_mode 'on'";
        }
        {
          plugin = tmuxPlugins.extrakto;
          extraConfig = "set -g @extrakto_split_direction 'v'";
        }
      ];
      extraConfig = ''
        ${builtins.readFile ./tmux.conf}
      '';
    };
  };

}
