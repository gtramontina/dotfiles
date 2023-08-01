{ config, pkgs, ... }:
let
  ext = publisher: name: version: sha256: pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = { inherit name publisher sha256 version; };
  };
in
{
  programs.vscode = {
    enable = true;
    enableExtensionUpdateCheck = true;
    extensions = (with pkgs.vscode-extensions; [
      editorconfig.editorconfig
      github.vscode-github-actions
      github.github-vscode-theme
      github.copilot-chat
      github.copilot
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
      ms-vscode.makefile-tools
      ms-azuretools.vscode-docker
      ms-vscode.makefile-tools
      golang.go
    ]) ++ [
      (ext "isudox" "vscode-jetbrains-keybindings" "0.1.9" "sha256-Y+g6eNp4aRqVisyp+LqtN/iSZ6fzkVTFCLPTE3KoYDk=")
      (ext "vlanguage" "vscode-vlang" "0.1.14" "sha256-hlBALxBs5wZZFk4lgAkdkGs731Xuc2p0qxffOW6mMWQ=")
      (ext "rubymaniac" "vscode-direnv" "0.0.2" "sha256-TVvjKdKXeExpnyUh+fDPl+eSdlQzh7lt8xSfw1YgtL4=")
      (ext "a-h" "templ" "0.0.19" "sha256-S6evBykYlRmr5GLePnWyZOweaYfWqf0oGCoOpxZXJhs=")
      (ext "benspaulding" "procfile" "1.1.7" "sha256-UP/FT/bG22sTbMtVIEOEd2cdkBuLiBwmYitAXCIhUCQ=")
      (ext "oven" "bun-vscode" "0.0.12" "sha256-8+Fqabbwup6Jzm5m8GlWbxTqumqXtWAw5s3VaDht9Us=")
      (ext "biomejs" "biome" "2.1.2" "sha256-bPAig5KK6hYxyAyt48Mfi2dEf50/hNiNngX7bTzIKcQ=")
    ];

    userSettings = {
      "telemetry.telemetryLevel" = "off";
      "editor.fontFamily" = "Berkeley Mono";
      "editor.minimap.enabled" = false;
      "editor.renderWhitespace" = "all";
      "editor.formatOnSave" = true;
      "editor.renderLineHighlight" = "gutter";
      "editor.rulers" = [
        80
        120
      ];

      "window.autoDetectHighContrast" = false;
      "window.autoDetectColorScheme" = true;

      "workbench.activityBar.location" = "hidden";
      # "workbench.iconTheme" = "catppuccin-mocha";
      "workbench.iconTheme" = "catppuccin-frappe";
      "workbench.colorTheme" = "Catppuccin Frappé";
      # "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
      # "workbench.preferredLightColorTheme" = "Catppuccin Frappé";
      "workbench.tree.indent" = 16;
      "workbench.tree.renderIndentGuides" = "always";
      "workbench.startupEditor" = "none";

      "explorer.compactFolders" = false;

      "files.autoSave" = "onFocusChange";

      "v.vls.enable" = true;

      # "[javascript]" = {
      #   "editor.defaultFormatter" = "biomejs.biome";
      # };
      # "[typescript]" = {
      #   "editor.defaultFormatter" = "biomejs.biome";
      # };
      # "[json]" = {
      #   "editor.defaultFormatter" = "biomejs.biome";
      # };
    };
  };

}
