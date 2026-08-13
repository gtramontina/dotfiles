{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    hunk.url = "github:modem-dev/hunk";
    hunk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    darwin,
    home-manager,
    nixpkgs,
    # nix-vscode-extensions,
    ...
  }: {
    darwinConfigurations = {
      gtramontina = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin
          home-manager.darwinModules.home-manager
          ./homebrew
        ];
      };
      gtramontina-work = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin
          home-manager.darwinModules.home-manager
          ./homebrew
        ];
      };
    };

    homeConfigurations = {
      gtramontina = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowBroken = true;
          config.allowUnfree = true;
          config.enableCgo = true;
        };

        extraSpecialArgs = {inherit inputs;};
        modules = [./home-manager];
      };
      gtramontina-work = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowBroken = true;
          config.allowUnfree = true;
          config.enableCgo = true;
        };

        extraSpecialArgs = {inherit inputs;};
        modules = [./home-manager];
      };
    };

    apps."aarch64-darwin".default = let
      pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      init = pkgs.writeShellApplication {
        name = "init";
        runtimeInputs = with pkgs; [git curl bash];
        text = builtins.readFile ./init.sh;
      };
    in {
      type = "app";
      program = "${init}/bin/init";
    };
  };
}
