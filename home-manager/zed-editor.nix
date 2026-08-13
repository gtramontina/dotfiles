{
  config,
  pkgs,
  ...
}: {
  programs.zed-editor = {
    enable = true;

    # I'm using Zed Preview (installed via homebrew). This is only to keep the
    # dotfiles tracked with nix.
    package = null;

    extraPackages = [
      # pkgs.nixd
    ];

    extensions = [
      # "biome"
      # "catppuccin"
      # "catppuccin-icons"
      "crystal"
      "dockerfile"
      "emmet"
      "git-firefly"
      "html"
      "lean4"
      "lua"
      # "matte-black"
      "make"
      "nix"
      "templ"
      "toml"
      "xml"
    ];

    userSettings = {
      project_panel = {
        auto_fold_dirs = false;
      };
      outline_panel = {
        auto_fold_dirs = false;
      };

      autosave = "on_focus_change";
      base_keymap = "JetBrains";
      buffer_font_family = "Berkeley Mono";
      buffer_font_size = 12;
      confirm_quit = true;
      icon_theme = {
        mode = "system";
        # dark = "Matte Black";
        # light = "Matte Black";
        # dark = "Catppuccin Frappé";
        # light = "Catppuccin Latte";
      };
      show_whitespaces = "all";
      terminal = {
        font_family = "Berkeley Mono";
        font_size = 12;
      };
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      theme = {
        mode = "system";
        # dark = "Matte Black";
        # light = "Matte Black";
        # dark = "Catppuccin Frappé";
        # light = "Catppuccin Latte";
      };
      ui_font_family = "Berkeley Mono";
      ui_font_size = 13;
      wrap_guides = [80 120];

      agent_servers = {
        "claude-acp" = {
          type = "registry";
        };
        OpenCode = {
          type = "custom";
          command = "opencode";
          args = ["acp"];
        };
      };
    };

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          "alt+f12" = "terminal_panel::ToggleFocus";
          # "cmd-shift-'": "workspace::ToggleZoom";
          # "cmd-shift-f12": "workspace::ToggleZoom";
        };
      }
    ];
  };
}
