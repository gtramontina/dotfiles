{
  username = "colleague";
  fullName = "Colleague Example";
  homeDirectory = "/srv/home/colleague";

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
