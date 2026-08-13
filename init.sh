echo "⚡️ Initializing…"

nix flake update

nix run home-manager/master -- switch --flake .
sudo nix run nix-darwin -- switch --flake .
nix-collect-garbage
sudo nix-collect-garbage

