{
  lib,
  pkgs,
  profile ? "personal",
  ...
}: {
  programs.opencode = {
    enable = true;

    # Remove once nixpkgs includes https://github.com/NixOS/nixpkgs/pull/582675.
    package =
      if (pkgs.opencode.node_modules.outputHash or null) == "sha256-xfOVcw1+waLVNhFDwzOtzxrUSQEogvn88YomydOlhwc="
      then
        pkgs.opencode.overrideAttrs (old: {
          node_modules = old.node_modules.overrideAttrs {
            outputHash =
              if pkgs.stdenv.hostPlatform.isDarwin
              then "sha256-dIveiaiPFGSItwLyeMuPDxTE9gpvvnlTCB/+nG24qCc="
              else "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
          };
        })
      else pkgs.opencode;

    settings =
      {
        plugin = [
          # "opencode-gemini-auth@latest"
        ];
      }
      // lib.optionalAttrs (profile == "work") {
        provider.lmstudio = {
          npm = "@ai-sdk/openai-compatible";
          name = "LM Studio (local)";
          options.baseURL = "http://127.0.0.1:1234/v1";
          models."qwen/qwen3.8-27b" = {
            name = "Qwen3.8 27B GGUF Q4_K_M (local)";
            limit = {
              context = 16384;
              output = 4096;
            };
          };
        };
      };
  };
}
