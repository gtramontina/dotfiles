{
  username = "colleague";
  fullName = "Colleague Example";
  homeDirectory = "/srv/home/colleague";
  dotfilesDirectory = "/srv/config/dotfiles";

  profiles = {
    personal = {
      email = "personal@example.com";
      signingKey = "";
    };

    work = {
      email = "work@example.com";
      signingKey = "AAAAAAAAAAAAAAAA";
    };
  };
}
