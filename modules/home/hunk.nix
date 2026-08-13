{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.hunk.homeManagerModules.default];

  programs.hunk = {
    # enable = true;
    # enableGitIntegration = true;
  };
}
