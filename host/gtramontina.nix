{ config, pkgs, ... }:
let

  username = "gtramontina";

in
{
  system.stateVersion = 4;

  imports = [
    <home-manager/nix-darwin>
    ./system-preferences
    ./homebrew
  ];

  users = { users = { ${username} = { home = "/Users/${username}"; }; }; };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.${username} = (import ./home-manager);
  };

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-old";

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
    tarball-ttl = 604800; # 7 days
  };

  programs.zsh.enable = true;
  environment = {
    shells = with pkgs; [ zsh ];
    pathsToLink = [ "/Applications" ];
  };

}
