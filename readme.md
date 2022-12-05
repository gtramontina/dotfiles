<h1 align="center">
	<img src="https://img.icons8.com/stickers/500/null/circled-menu.png" width="130"><br>.dotfiles<br>
	<sup><sup><sup><sup>System Setup</sup></sup></sup></sup>
</h1>

### <img src="https://img.icons8.com/stickers/200/null/keyboard.png" width="18"> One-liner

```shell
curl -Ls https://raw.githubusercontent.com/gtramontina/dotfiles/master/setup.sh | bash -s <hostname>
```

### <img src="https://img.icons8.com/stickers/200/null/info.png" width="18"> What?

The `setup.sh` script will install, if not already available:

* `git` via `xcode-select`;
* `homebrew` via the official [one-liner](https://brew.sh/);
* `nix` via the official [one-liner](https://nixos.org/download.html);
* `home-manager` nix channel;
* `nix-darwin` following the [instructions](https://github.com/LnL7/nix-darwin#install) from the official repository;

It'll, then, proceed with running `darwin-installer` built in the last step. This will get the systems ready to go. Subsequent changes to any `.nix` files can be applied by running `update` (a shell alias for `darwin-rebuild switch`).

---

<p align="right"><sub><sup>
	<i>Icons by <a href="https://icons8.com">Icons8 <img src="https://img.icons8.com/material-rounded/24/null/icons8-new-logo.png" width="10"/></a>.</i>
</sup></sub></p>
