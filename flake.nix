{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    hunk.url = "github:modem-dev/hunk";
    hunk.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    darwin,
    home-manager,
    nixpkgs,
    treefmt-nix,
    ...
  }: let
    systems = ["aarch64-darwin" "x86_64-linux"];
    eachSystem = nixpkgs.lib.genAttrs systems;

    identityPath = builtins.getEnv "DOTFILES_IDENTITY";
    identity = import (
      if identityPath != ""
      then identityPath
      else ./identity
    );
    identityFor = system: let
      homeDirectory =
        if identity.homeDirectory != null
        then identity.homeDirectory
        else if nixpkgs.lib.hasSuffix "-darwin" system
        then "/Users/${identity.username}"
        else "/home/${identity.username}";
    in
      identity
      // {
        inherit homeDirectory;
        dotfilesDirectory =
          if (identity.dotfilesDirectory or null) != null
          then identity.dotfilesDirectory
          else "${homeDirectory}/.dotfiles";
      };

    mkTreefmt = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      (treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        settings.global.excludes = ["./.git/**" "./.cache/**"];
        programs.alejandra.enable = true;
        programs.shfmt = {
          enable = true;
          includes = [
            "*.sh"
            "*.bash"
            "*.bats"
            "*.envrc"
            "*.envrc.*"
            "scripts/install"
            "scripts/setup"
            "tests/fixtures/commands/*"
            "tests/fixtures/old-nix/*"
          ];
        };
      }).config;

    mkDevShell = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      bats = pkgs.bats.withLibraries (libraries: [
        libraries.bats-assert
        libraries.bats-file
        libraries.bats-support
      ]);
    in
      pkgs.mkShell {
        packages = [
          pkgs.actionlint
          pkgs.alejandra
          bats
          pkgs.expect
          pkgs.gnumake
          pkgs.rsync
          pkgs.shfmt
          pkgs.shellcheck
          pkgs.git
          (mkTreefmt system).build.wrapper
        ];
        shellHook = "echo '💻 dotfiles dev shell — `make check` to lint, `make fmt` to format'";
      };

    mkChecks = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      shellSources = nixpkgs.lib.fileset.toSource {
        root = ./.;
        fileset = nixpkgs.lib.fileset.unions [./scripts ./tests];
      };
    in {
      actionlint =
        pkgs.runCommand "dotfiles-actionlint" {
          nativeBuildInputs = [pkgs.actionlint];
        } ''
          cd ${self}
          actionlint .github/workflows/*.yml
          touch $out
        '';
      treefmt = (mkTreefmt system).build.check self;
      shellcheck =
        pkgs.runCommand "dotfiles-shellcheck" {
          nativeBuildInputs = [pkgs.shellcheck];
        } ''
          cd ${shellSources}
          shellcheck scripts/install scripts/setup \
            tests/fixtures/commands/* tests/fixtures/old-nix/*
          shellcheck --shell=bash tests/*.bats
          touch $out
        '';
    };

    mkDarwin = system: profile: hostname: let
      identity = identityFor system;
    in
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit identity profile;
        };
        modules = [
          ./modules/darwin.nix
          ./modules/homebrew.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = {
              inherit identity inputs profile;
            };
            home-manager.users.${identity.username}.imports = [
              ./modules/profiles
              ./hosts/${hostname}.nix
            ];
          }
        ];
      };

    mkHome = system: profile: hostname: let
      identity = identityFor system;
    in
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          inherit identity inputs profile;
        };
        modules = [
          ./modules/profiles
          ./hosts/${hostname}.nix
        ];
      };
  in {
    formatter = eachSystem (system: (mkTreefmt system).build.wrapper);
    devShells = eachSystem (system: {default = mkDevShell system;});
    checks = eachSystem mkChecks;
    packages = eachSystem (system:
      if nixpkgs.lib.hasSuffix "-darwin" system
      then {darwin-rebuild = darwin.packages.${system}.darwin-rebuild;}
      else {home-manager = home-manager.packages.${system}.home-manager;});

    darwinConfigurations = {
      orion = mkDarwin "aarch64-darwin" "personal" "orion";
      phoenix = mkDarwin "aarch64-darwin" "work" "phoenix";
    };

    homeConfigurations = {
      "${identity.username}@cygnus" = mkHome "x86_64-linux" "personal" "cygnus";
    };
  };
}
