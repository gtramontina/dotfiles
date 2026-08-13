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

    mkTreefmt = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      (treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        settings.global.excludes = ["./.git/**" "./.cache/**"];
        programs.alejandra.enable = true;
        programs.shfmt.enable = true;
      }).config;

    mkDevShell = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      pkgs.mkShell {
        packages = [
          pkgs.alejandra
          pkgs.shfmt
          pkgs.shellcheck
          pkgs.git
          (mkTreefmt system).build.wrapper
        ];
        shellHook = "echo '💻 dotfilez dev shell — `make check` to lint, `make fmt` to format'";
      };

    mkChecks = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      scripts = nixpkgs.lib.fileset.toSource {
        root = ./.;
        fileset = nixpkgs.lib.fileset.unions [./scripts];
      };
    in {
      treefmt = (mkTreefmt system).build.check self;
      shellcheck =
        pkgs.runCommand "dotfilez-shellcheck" {
          nativeBuildInputs = [pkgs.shellcheck];
        } ''
          cd ${scripts}/scripts
          shellcheck ./*.sh
          touch $out
        '';
    };

    mkDarwin = system: profile: hostname:
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {inherit inputs profile;};
        modules = [
          ./modules/darwin.nix
          ./modules/homebrew.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = {inherit inputs profile;};
            home-manager.users.gtramontina.imports = [./hosts/${hostname}.nix];
          }
        ];
      };

    mkHome = system: profile: hostname:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = {inherit inputs profile;};
        modules = [./hosts/${hostname}.nix];
      };
  in {
    formatter = eachSystem (system: (mkTreefmt system).build.wrapper);
    devShells = eachSystem (system: {default = mkDevShell system;});
    checks = eachSystem mkChecks;

    darwinConfigurations = {
      orion = mkDarwin "aarch64-darwin" "personal" "orion";
      phoenix = mkDarwin "aarch64-darwin" "work" "phoenix";
    };

    homeConfigurations = {
      "gtramontina@cygnus" = mkHome "x86_64-linux" "personal" "cygnus";
    };
  };
}
