# Environment-variable placement

Verified **2026-11-11** against this repository's locked nix-darwin `ff0e21a` and Home Manager `a9752a6`. The configuration declares shell defaults only. No configuration activation, logout/reboot, or GUI environment tests were performed.

## Recommendation

**Declare the defaults only in `home.sessionVariables` on both operating systems.** The shared home module sets `DISABLE_TELEMETRY=1`, `DO_NOT_TRACK=1`, and `OTEL_SDK_DISABLED=true`; no `launchd.user.envVariables` assignments are declared. No additional application-specific aliases, shared-map abstraction, or global login machinery is justified by the currently verified consumers.

This gives durable defaults for ordinary managed shells and their descendants. The [existing telemetry research](telemetry-opt-outs.md) verifies these variables for CLI tools; no GUI-only consumer requiring them has been established. Use native GUI preferences where available: [Zed's module](../modules/home/zed-editor.nix) already disables `telemetry.metrics` and `telemetry.diagnostics`, the settings [Zed documents](https://zed.dev/docs/telemetry#configuring-telemetry-settings) for client-side usage metrics and crash reports.

This recommendation means **off by default in managed shell environments**, with application overrides. It does not claim universal macOS GUI or Linux service coverage. Removing Home Manager on macOS would instead make shells depend on launchd state that the pinned implementation does not reliably restore.

| Arrangement | What it buys | Decision |
| --- | --- | --- |
| Home Manager only, plus native GUI settings | Managed shells and their descendants on macOS/Linux; verified GUI controls | Recommended: smallest setup supported by current consumers. |
| macOS launchd only; Home Manager on Linux | Fewer macOS exports | Reject: relies on launch context and dynamic state; loses independent shell initialization. |
| One map, delivered to both | Removes repeated declarations and preserves additional launchd delivery | Reasonable only for a verified need; does not fix the desktop lifecycle gap below. |

The repository already uses integrated Home Manager on `orion`/`phoenix` and standalone Home Manager on Linux `cygnus`; all import the [shared home module](../modules/home/default.nix) and its [Zsh module](../modules/home/zsh.nix). See [flake wiring](../flake.nix).

## Why launchd is not an OS-wide variable store

Apple's installed `launchctl(1)` manual (`man 1 launchctl`), inspected on macOS 27.0.1, describes `setenv` as affecting future processes launched in the caller's context. Its domain definitions distinguish the system domain, a UID's user domain, and its GUI login domain. The user domain can exist without a GUI login; these are not interchangeable scopes.

The pinned [nix-darwin implementation](https://github.com/LnL7/nix-darwin/blob/ff0e21a414d4547183396da1b44a66f2577b65e9/modules/system/launchd.nix#L137-L148) executes `sudo --user=primaryUser -- launchctl setenv …` during user-launchd activation. It targets the configured primary user's launchd context, not every user's environment or every process running under that UID. Unlike its agent-loading commands, this call does not explicitly select a bootstrap with `launchctl asuser`; exact propagation into a particular login path requires runtime verification.

An already-running terminal, editor, or desktop launcher retains its environment. Its subsequently spawned children can therefore retain old values too. Apple's `Process.environment` documents inheritance from the creating process and rejects changes to its launch environment once the process has started. [Apple process environment documentation](https://developer.apple.com/documentation/foundation/process/environment)

## The lifecycle gap in this pinned nix-darwin

Full [`activate`](https://github.com/LnL7/nix-darwin/blob/ff0e21a414d4547183396da1b44a66f2577b65e9/modules/system/activation-scripts.nix#L114-L140) runs `userLaunchd`. [`darwin-rebuild switch` and `activate`](https://github.com/LnL7/nix-darwin/blob/ff0e21a414d4547183396da1b44a66f2577b65e9/pkgs/nix-tools/darwin-rebuild.sh#L240-L248) invoke that full activation.

Boot behaves differently. The always-enabled `org.nixos.activate-system` daemon has `RunAtLoad=true`, but its [actual startup script](https://github.com/LnL7/nix-darwin/blob/ff0e21a414d4547183396da1b44a66f2577b65e9/modules/services/activate-system/default.nix#L34-L72) runs only `checks`, `etc`, and `keyboard` fragments. It does **not** run `userLaunchd`. The environment option creates no separate login agent replaying these values.

**Inference from that implementation:** declarative values remain in the Nix configuration, but the dynamic `setenv` state has no demonstrated reboot/login restoration. Logout/login is also not a persistence guarantee: user and GUI-domain lifetimes differ. Apple provides a separately named persistent `launchctl config` facility, but its environment-variable support is limited to `PATH` (`man 1 launchctl`). Calling `setenv` once must not be described as persistent configuration.

There is also an activation-order issue: [`userDefaults` precedes `userLaunchd`](https://github.com/LnL7/nix-darwin/blob/ff0e21a414d4547183396da1b44a66f2577b65e9/modules/system/activation-scripts.nix#L125-L129), and [can restart Dock](https://github.com/LnL7/nix-darwin/blob/ff0e21a414d4547183396da1b44a66f2577b65e9/modules/system/defaults-write.nix#L154-L156). Source ordering alone cannot prove a Dock-launched application receives the new defaults.

## Why the shell route still matters

Home Manager generates [`hm-session-vars.sh`](https://github.com/nix-community/home-manager/blob/a9752a621164e9f84eb2a15858f1d54fd3cedab8/modules/home-environment.nix#L701-L718): a once-per-inherited-environment guard followed by exports. Its [Zsh integration](https://github.com/nix-community/home-manager/blob/a9752a621164e9f84eb2a15858f1d54fd3cedab8/modules/programs/zsh/default.nix#L578-L590) sources that file from `.zprofile` for login shells and `.zshenv` for non-login shells. These startup paths cover ordinary managed Zsh sessions independently of a GUI parent, including SSH when Zsh is the account shell. [Zsh startup rules](https://zsh.sourceforge.io/Doc/Release/Files.html#Startup_002fShutdown-Files), [OpenSSH session startup](https://man.openbsd.org/sshd.8#LOGIN_PROCESS)

If launchd already supplied the same value, the first shell export repeats an assignment. It does not create two independent values for the application; the exported variable has one effective value. The guard avoids repeating Home Manager's exports in ordinary descendant shells. Thus two delivery routes can be legitimate, but this repository currently establishes a need for only the shell route.

## Explicit application opt-in

Apply an override **at the final application invocation**, after shell initialization:

```sh
env OTEL_SDK_DISABLED=false your-command
```

A project environment loaded after startup can do the same. Conversely, `env OTEL_SDK_DISABLED=false zsh -lc 'your-command'` can be reset to `true` when Home Manager's session-variable guard is absent and initialization runs. The source above exports configured values unconditionally after that guard. For a fresh login shell, put the override inside its command: `zsh -lc 'env OTEL_SDK_DISABLED=false your-command'`.

`false` removes the OpenTelemetry SDK disable switch in implementations supporting it; it does not configure an exporter or override unrelated product preferences. [OpenTelemetry specification](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/#general-sdk-configuration)

## When broader GUI coverage is justified

First identify an application that honors one of these variables and needs it outside a managed shell. Prefer its native setting or a per-application launch environment. For a managed launchd job, `EnvironmentVariables` configures that job directly (`man 5 launchd.plist`); [nix-darwin exposes it](https://github.com/LnL7/nix-darwin/blob/ff0e21a414d4547183396da1b44a66f2577b65e9/modules/launchd/default.nix#L28-L35) through the job's `environment` option.

Only if all GUI launches truly require shared variables should a user `RunAtLoad` LaunchAgent replay `launchctl setenv` at login. Apple documents [login agent loading and unordered startup](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html#//apple_ref/doc/uid/20001981-CH3-SW2): such an agent does not itself guarantee it beats restored applications or desktop launchers. Fresh login/reboot and the actual application launch path would need verification. There is no demonstrated need for that mechanism here today.
