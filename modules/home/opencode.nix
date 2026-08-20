{
  lib,
  profile ? "personal",
  ...
}: {
  programs.opencode = {
    enable = true;

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
