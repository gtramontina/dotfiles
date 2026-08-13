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

  outputs = inputs@{ self, darwin, home-manager, nixpkgs, ... }:
    let
      mkDarwin = system: profile: hostname:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs profile; };
          modules = [
            ./modules/darwin.nix
            ./modules/homebrew.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = { inherit inputs profile; };
              home-manager.users.gtramontina.imports = [ ./hosts/${hostname}.nix ];
            }
          ];
        };

      mkHome = system: profile: hostname:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit inputs profile; };
          modules = [ ./hosts/${hostname}.nix ];
        };
    in
    {
      darwinConfigurations = {
        orion = mkDarwin "aarch64-darwin" "personal" "orion";
        phoenix = mkDarwin "aarch64-darwin" "work" "phoenix";
      };

      homeConfigurations = {
        "gtramontina@cygnus" = mkHome "x86_64-linux" "personal" "cygnus";
      };
    };
}
