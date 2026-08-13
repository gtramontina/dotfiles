{ pkgs, ... }: {
  home.packages = with pkgs; [
  ];

  programs.git.settings.user = {
    name = "Guilherme J. Tramontina";
    email = "gtramontina@company.com";
  };
}
