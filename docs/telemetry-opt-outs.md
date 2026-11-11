# Developer-tool telemetry opt-outs

Verified: **2026-11-11**. Scope: terminal-launched developer tools, their product analytics, and relevant desktop settings. Sources are official documentation and first-party code. This is a configuration research note, not a network-capture audit; an opt-out does not establish that a tool makes no other requests.

## Recommendation

Use shared preferences first and add a product-specific flag only for a confirmed gap. Configured defaults are:

```sh
export DO_NOT_TRACK=1
export DISABLE_TELEMETRY=1
export HOMEBREW_NO_ANALYTICS=1
export OTEL_SDK_DISABLED=true
```

These defaults are declared only in Home Manager's `home.sessionVariables`. See [environment-variable placement](environment-variable-scope.md) for the implementation evidence and GUI coverage limits.

Sources and limits are below. `DO_NOT_TRACK` is a [voluntary proposal](https://donottrack.sh/), not a universal switch. Applications must implement shared names such as it and `DISABLE_TELEMETRY`.

Leave `GH_TELEMETRY` unset: [GitHub CLI honors `DO_NOT_TRACK=1`](https://cli.github.com/manual/gh_help_environment), so its dedicated flag adds no coverage here. Likewise, the verified Scarf npm/Go clients, Turborepo, Nuxt, and Hugging Face already honor `DO_NOT_TRACK`; their dedicated flags below are alternatives, not additions to this baseline. The linked implementations and documentation in the tables establish that overlap.

`DISABLE_ERROR_REPORTING=1` covers a separate Claude Code reporting path; it is documented below but is not configured. Add further settings only for relevant tools whose reporting is not covered by the shared defaults.

The policy is to disable OpenTelemetry by default in managed environments and enable it explicitly for applications that need it. Override the inherited default with `OTEL_SDK_DISABLED=false` in the project's environment after shell startup, or run `env OTEL_SDK_DISABLED=false your-command`. This permits SDK observability in implementations supporting the variable. [OpenTelemetry specification](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/)

## Broad preferences and package analytics

| Setting | What it stops | Limits and value syntax | Primary source |
| --- | --- | --- | --- |
| `DO_NOT_TRACK=1` | Telemetry in participating applications. Verified examples include Turborepo, Nuxt/Nuxt DevTools, Hugging Face Hub, and Scarf's npm client. | A voluntary convention, not an OS or network control. Use `1` for the convention; do not assume every implementation accepts `true`. | [Proposal](https://donottrack.sh/), [Turborepo](https://turborepo.dev/docs/telemetry), [Nuxt module](https://github.com/nuxt/telemetry/blob/main/src/module.ts), [Nuxt DevTools](https://github.com/nuxt/devtools#anonymous-usage-analytics), [HF variables](https://huggingface.co/docs/huggingface_hub/en/package_reference/environment_variables#do_not_track), [Scarf npm](https://github.com/scarf-sh/scarf-js#as-a-user-of-a-package-using-scarf-js-how-can-i-opt-out-of-analytics) |
| `SCARF_NO_ANALYTICS=true` | Scarf reporting in integrations honoring this variable, including the npm client's legacy opt-out. | Unset here: `DO_NOT_TRACK=1` covers the verified npm/Go clients. For use as an alternative, lowercase `true` is exact in scarf-js; the Go SDK documents `1`. This does not configure browser headers or all Scarf Gateway download analytics. | [Scarf npm implementation](https://github.com/scarf-sh/scarf-js/blob/master/report.js#L51-L55), [Scarf SDK guidance](https://docs.scarf.sh/sdk-capability-map/), [Go SDK](https://github.com/scarf-sh/scarf-go#configuration), [Gateway DNT headers](https://docs.scarf.sh/gateway/#do-not-track) |
| `SCARF_ANALYTICS=false` | Scarf npm installation analytics. | Current documented npm-specific opt-out; exact lowercase `false`. `SCARF_NO_ANALYTICS` is retained in source with a comment describing it as the original variable. `DO_NOT_TRACK=1` already covers the current npm client. | [Scarf npm documentation](https://github.com/scarf-sh/scarf-js#configuring), [implementation](https://github.com/scarf-sh/scarf-js/blob/master/report.js#L51-L55) |
| `DISABLE_TELEMETRY=1` | Telemetry only in applications that implement this name; current Hugging Face Hub code is one verified adopter. | Keep it as an additional preference, but do not assume it substitutes for each product's variable. HF accepts `1`, `ON`, `YES`, `TRUE`, case-insensitively. | [HF constants and parsing](https://github.com/huggingface/huggingface_hub/blob/main/src/huggingface_hub/constants.py) |

## Frameworks and component tooling

These switches disable each tool's own usage reporting. They are not controls for analytics deliberately added to the application you build.

| Tool | Documented environment setting | Effect and useful limits | Primary source |
| --- | --- | --- | --- |
| Next.js | `NEXT_TELEMETRY_DISABLED=1` | Opts out of Next.js usage telemetry. Alternative: `next telemetry disable`; inspect with `next telemetry status`. | [Next.js telemetry](https://nextjs.org/telemetry#how-do-i-opt-out) |
| Turborepo | `TURBO_TELEMETRY_DISABLED=1` | Disables command/host usage telemetry. Also honors `DO_NOT_TRACK=1`, so the dedicated flag is optional when the shared flag is exported. Alternative: `turbo telemetry disable`; inspect with `turbo telemetry status`. | [Turborepo telemetry](https://turborepo.dev/docs/telemetry) |
| Astro | `ASTRO_TELEMETRY_DISABLED=1` | Disables all Astro telemetry, including CLI/configuration and toolbar usage reporting. Alternative: `astro telemetry disable` stores a machine-wide preference. | [Astro telemetry](https://astro.build/telemetry/) |
| Nuxt | `NUXT_TELEMETRY_DISABLED=1` | Disables Nuxt telemetry before consent handling; current code also honors `DO_NOT_TRACK`. The source helper accepts exact `1` or lowercase `true`. Nuxt asks permission on first use; `telemetry: false` is a project alternative. | [Nuxt documentation](https://github.com/nuxt/telemetry#opting-out), [module](https://github.com/nuxt/telemetry/blob/main/src/module.ts), [boolean helper](https://github.com/nuxt/telemetry/blob/main/src/utils/env.ts) |
| Gatsby | `GATSBY_TELEMETRY_DISABLED=1` | Disables Gatsby usage telemetry and CLI feedback prompts. Alternative: `gatsby telemetry --disable`. | [Gatsby telemetry](https://www.gatsbyjs.com/docs/telemetry/), [feedback prompts](https://www.gatsbyjs.com/docs/cli-feedback/) |
| Storybook | `STORYBOOK_DISABLE_TELEMETRY=true` | Disables usage telemetry, including the early `boot` event sent before configuration is evaluated. This covers more than only setting `core.disableTelemetry` in project configuration. | [Storybook telemetry](https://storybook.js.org/docs/configure/telemetry#how-to-opt-out) |

## SDKs, shells, and cloud CLIs

| Tool | Documented environment setting | Effect and useful limits | Primary source |
| --- | --- | --- | --- |
| .NET SDK / CLI | `DOTNET_CLI_TELEMETRY_OPTOUT=1` | Disables SDK/CLI usage and exception telemetry; `true` and `yes` are also accepted. Set before installation to suppress the installer's single successful-install event. This is not a switch for telemetry inside arbitrary .NET applications. | [.NET telemetry](https://learn.microsoft.com/en-us/dotnet/core/tools/telemetry), [accepted values](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-environment-variables#dotnet_cli_telemetry_optout) |
| PowerShell | `POWERSHELL_TELEMETRY_OPTOUT=1` | Disables PowerShell's Microsoft telemetry. Also accepts `true` or `yes`. Must be set **before starting** `pwsh`; setting it in the PowerShell profile is too late for startup telemetry. | [PowerShell telemetry](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_telemetry?view=powershell-7.6) |
| Hugging Face libraries | `HF_HUB_DISABLE_TELEMETRY=1` | Disables the shared telemetry implementation used by participating HF Python libraries. Accepted true values: `1`, `ON`, `YES`, `TRUE`, case-insensitive. `DO_NOT_TRACK` is documented as equivalent; current source also recognizes `DISABLE_TELEMETRY`. This does not mean offline mode. | [HF environment variables](https://huggingface.co/docs/huggingface_hub/en/package_reference/environment_variables#hfhubdisabletelemetry), [implementation](https://github.com/huggingface/huggingface_hub/blob/main/src/huggingface_hub/constants.py) |
| AWS SAM CLI | `SAM_CLI_TELEMETRY=0` | Disables SAM CLI usage metrics, system/environment data, and error diagnostics. AWS documents this exact shell value; it applies to SAM CLI rather than all AWS SDKs or services. | [AWS SAM telemetry](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-telemetry.html) |
| Azure CLI | `AZURE_CORE_COLLECT_TELEMETRY=false` | Disables Azure CLI usage collection. The documented `AZURE_{section}_{name}` mapping gives this environment name for `core.collect_telemetry`; false values are `0`, `no`, `false`, `off`, case-insensitive. Alternative: `az config set core.collect_telemetry=false`. | [Azure configuration mapping and booleans](https://learn.microsoft.com/en-us/cli/azure/azure-cli-configuration?view=azure-cli-latest), [data collection](https://learn.microsoft.com/en-us/cli/azure/what-is-azure-cli?view=azure-cli-latest#data-collection) |

Go is a useful counterexample: use **`go telemetry off`**, available since Go 1.23, to disable collection and uploading. The default is `local`, which collects locally without uploads. `go env GOTELEMETRY` reports the setting; Go documents it as read-only, so `export GOTELEMETRY=off` is not the configuration mechanism. See [Go's telemetry documentation](https://go.dev/doc/telemetry#configuration).

## Application observability: off by default, with explicit opt-in

| Setting | Actual behavior | Scope and override | Primary source |
| --- | --- | --- | --- |
| `OTEL_SDK_DISABLED=true` | Uses a no-op SDK for all signals in implementations supporting this variable. The specification accepts only case-insensitive `true`; `1` is not true. It does not disable propagators. | Configured for managed shells; projects opt in with `OTEL_SDK_DISABLED=false` after shell startup. Environment configuration is optional for SDK implementations, and the standard Go SDK currently does not support this variable. | [OpenTelemetry specification](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/), [Go support limit](https://opentelemetry.io/docs/languages/go/exporters/) |
| `OTEL_TRACES_EXPORTER=none`, `OTEL_METRICS_EXPORTER=none`, `OTEL_LOGS_EXPORTER=none` | Disables automatically configured exporters for the corresponding signals. | Optional separate controls; this setup does not export them. They do not promise to override manually configured exporters. The spec also says `OTEL_CONFIG_FILE`, when used, overrides environment configuration except substitutions referenced inside that file. | [Exporter selection and configuration precedence](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/#exporter-selection) |

## Installed tools

Configured state: [Home Manager](../modules/home/default.nix) exports `DO_NOT_TRACK=1`, `DISABLE_TELEMETRY=1`, `HOMEBREW_NO_ANALYTICS=1`, and `OTEL_SDK_DISABLED=true` for managed shells and their descendants. No launchd environment assignments are declared. [Zed](../modules/home/zed-editor.nix) already sets both telemetry options to `false`. The VS Code module is not imported; its `telemetry.feedback.enabled=false` does not establish telemetry is disabled.

| Tool | Verified opt-out and practical limits | Primary source |
| --- | --- | --- |
| Claude Code | Existing `DISABLE_TELEMETRY=1` opts out of telemetry; `DO_NOT_TRACK=1` has the same effect. Add `DISABLE_ERROR_REPORTING=1` for separate error reporting. For the two `DISABLE_*` variables, **any nonempty value**, even `0`, disables reporting; unset to undo. Telemetry opt-out also disables feature-flag fetching, affecting features including synced skills/plugins. Avoid blanket `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`: it also disables updates and other features. | [Claude variables and feature limits](https://code.claude.com/docs/en/env-vars) |
| GitHub CLI 2.103.3 | Covered by `DO_NOT_TRACK=1`; leave `GH_TELEMETRY` unset. The dedicated flag (`false` or `0`) is an alternative that takes precedence. Usage telemetry was introduced in 2.91.0. Extensions have independent telemetry. | [Environment manual](https://cli.github.com/manual/gh_help_environment), [announcement](https://github.blog/changelog/2026-04-22-github-cli-opt-out-usage-telemetry/) |
| Devbox 0.18.4 | `DO_NOT_TRACK=1` disables reporting; the installed version's tagged code checks this before initializing Segment/Sentry. | [Documented value](https://www.jetify.com/blog/devbox-0-0-4-is-released), [0.18.4 implementation](https://github.com/jetify-com/devbox/blob/0.18.4/internal/telemetry/telemetry.go#L59) |
| Bun | `DO_NOT_TRACK=1` disables automatic crash-report uploads, which default on for macOS/Windows. Bun currently documents no other telemetry. | [Bun variables](https://bun.sh/docs/runtime/environment-variables) |
| Homebrew | Existing `HOMEBREW_NO_ANALYTICS=1` is the documented opt-out. Persistent alternative: `brew analytics off`. | [Homebrew analytics](https://github.com/Homebrew/brew/blob/master/docs/Analytics.md#opting-out) |
| Gemini CLI | Set `privacy.usageStatisticsEnabled=false` in `~/.gemini/settings.json` to disable default-on usage statistics; restart required. `GEMINI_TELEMETRY_ENABLED=false` controls a separate, default-off OpenTelemetry pipeline and does not establish product analytics are disabled. | [Usage-statistics configuration](https://geminicli.com/docs/reference/configuration/#privacy), [OpenTelemetry configuration](https://geminicli.com/docs/cli/telemetry/#configuration) |
| Codex 0.167.0 | Use `analytics.enabled=false` in config to disable built-in Statsig metrics. Explicit OTLP exporters remain independent: `otel.metrics_exporter`, `otel.exporter`, and `otel.trace_exporter` each accept `"none"`. No supported environment opt-out was established. `feedback.enabled=false` controls optional feedback, not background analytics. | [Official OpenAI configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference) |
| Zed | Existing `telemetry.metrics=false` and `telemetry.diagnostics=false` disable client usage/crash reporting. Hosted AI/collaboration services retain required server-side telemetry. | [Zed telemetry](https://zed.dev/docs/telemetry) |
| VS Code | If used, set `"telemetry.telemetryLevel": "off"` to disable VS Code crash/error/usage reporting. Extensions are independent. Opting out also disables A/B experimentation and may delay new features. | [VS Code telemetry](https://code.visualstudio.com/docs/configure/telemetry) |

OpenCode 2.2.5 remains unverified: no supported v2 telemetry flag was established. Do not infer v2 behavior from v1 documentation.

## Avoid confusing silence with opting out

- `DOTNET_NOLOGO=true` hides welcome/telemetry text and has **no effect** on telemetry opt-out. [.NET documentation](https://learn.microsoft.com/en-us/dotnet/core/tools/telemetry#disclosure)
- `TURBO_TELEMETRY_MESSAGE_DISABLED` hides the telemetry notice; the actual opt-out is `TURBO_TELEMETRY_DISABLED=1` or `DO_NOT_TRACK=1`. [Turborepo variable reference](https://turborepo.dev/docs/reference/system-environment-variables), [telemetry](https://turborepo.dev/docs/telemetry)
- `HF_HUB_DISABLE_UPDATE_CHECK=1` stops version/extension update checks and hints, a separate behavior from HF telemetry. Do not substitute it for `HF_HUB_DISABLE_TELEMETRY`. [HF variables](https://huggingface.co/docs/huggingface_hub/en/package_reference/environment_variables#hfhubdisableupdatecheck)

## Verification limits

Support in older releases, third-party wrappers, extensions, and unrelated dependencies remains outside this verification. For strict no-traffic requirements, inspect the exact installed version and verify requests separately.

Shell exports reach processes launched with that environment; desktop launchers may require separate settings. Apply declared environment defaults with `make switch`, then open a new terminal and restart applications.
