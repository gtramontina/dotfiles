{
  identity,
  lib,
  profile,
  ...
}: let
  gitIdentity = identity.profiles.${profile};
in {
  home = {
    inherit (identity) username;
    inherit (identity) homeDirectory;
  };

  programs.git = {
    settings.user = {
      name = identity.fullName;
      inherit (gitIdentity) email;
    };

    signing = lib.mkIf (gitIdentity.signingKey != "") {
      signByDefault = true;
      key = gitIdentity.signingKey;
    };
  };
}
