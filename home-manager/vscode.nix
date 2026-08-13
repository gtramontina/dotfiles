{pkgs, ...}: {
  programs.vscode = {
    enable = true;

    # mutableExtensionsDir = false;

    profiles.default = {
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;

      extensions =
        (with pkgs.vscode-marketplace; [
          # catppuccin.catppuccin-vsc
          # catppuccin.catppuccin-vsc-icons
          fogio.jetbrains-color-theme
          fogio.jetbrains-product-icon-theme
          fogio.jetbrains-file-icon-theme

          golang.go
          a-h.templ
          starfederation.datastar-vscode
          jnoortheen.nix-ide

          ms-vscode.makefile-tools
          mkhl.direnv

          usernamehw.errorlens
          pflannery.vscode-versionlens
          eamodio.gitlens

          bradlc.vscode-tailwindcss

          k--kato.intellij-idea-keybindings

          buenon.scratchpads
          xyz.local-history
        ])
        ++ (with pkgs.vscode-extensions; [
          #
        ]);

      userSettings = {
        "editor.fontFamily" = "'Berkeley Mono Variable'";
        "editor.inlineSuggest.enabled" = true;
        "editor.renderWhitespace" = "all";
        "editor.minimap.enabled" = false;
        "editor.rulers" = [80 120];
        "editor.semanticHighlighting.enabled" = true;
        "editor.colorDecorators" = true;

        "explorer.compactFolders" = false;
        "explorer.fileNesting.enabled" = true;
        "explorer.fileNesting.expand" = false;
        "explorer.fileNesting.patterns" = {
          "*.go" = "\${capture}_test.go";
          "go.mod" = "go.sum";
        };

        "files.autoSave" = "onFocusChange";
        "telemetry.feedback.enabled" = false;
        "terminal.integrated.minimumContrastRatio" = 1;

        "window.titleBarStyle" = "custom";
        "window.systemColorTheme" = "auto";
        "window.autoDetectColorScheme" = true;

        "workbench.activityBar.location" = "top";
        "workbench.tree.indent" = 16;
        "workbench.preferredDarkColorTheme" = "dark-jetbrains-color-theme";
        "workbench.preferredLightColorTheme" = "light-jetbrains-color-theme";
        "workbench.productIconTheme" = "jetbrains-product-icon-theme";
        "workbench.iconTheme" = "jetbrains-file-icon-theme-auto";

        "chat.agent.enabled" = true;
        "chat.mcp.enabled" = true;

        "github.copilot.nextEditSuggestions.enabled" = true;

        "tailwindCSS.emmetCompletions" = true;
        "tailwindCSS.includeLanguages" = {
          "templ" = "html";
        };

        "go.lintTool" = "golangci-lint";

        "mcp" = {
          "servers" = {
            "Context7" = {
              "type" = "stdio";
              "command" = "npx";
              "args" = ["-y" "@upstash/context7-mcp@latest"];
            };
          };
        };
      };
    };
  };
}
