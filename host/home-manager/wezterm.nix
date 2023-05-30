{ config, pkgs, ... }:
{

  programs.wezterm = {
    enable = true;

    extraConfig = ''
      return {
        window_frame = {
          active_titlebar_bg = '#171717',
          font = wezterm.font { family = 'Berkeley Mono Variable' },
        },
        keys = {
          {
            key = 'f',
            mods = 'CTRL|CMD',
            action = wezterm.action.ToggleFullScreen,
          }
        },
        window_decorations = "RESIZE",
        font = wezterm.font("Berkeley Mono Variable"),
        font_size = 12.0,
        color_scheme = "Ayu Mirage",
        use_fancy_tab_bar = false,
        tab_bar_at_bottom = true,
        show_new_tab_button_in_tab_bar = false,
        hide_tab_bar_if_only_one_tab = true,
        default_prog = { "zsh", "-c", "tmux new -DAs default" },
        window_close_confirmation = "NeverPrompt",
        window_padding = {
          left = 1,
          right = 1,
          top = 12,
          bottom = 1,
        },
      }
    '';
  };

}
