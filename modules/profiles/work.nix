{pkgs, ...}: {
  home.packages = with pkgs; [
  ];

  programs.git.settings.user = {
    name = "Guilherme J. Tramontina";
    email = "guilherme.tramontina@gmail.com";
  };
}
