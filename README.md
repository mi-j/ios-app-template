# mi-j iOS app template

Starter template for new iOS apps under the `mi-j` GitHub account.
Pre-wired: Fastlane (build / TestFlight / App Store), Match code signing
(reuses [`mi-j/ios-certificates`](https://github.com/mi-j/ios-certificates)),
Supabase + RevenueCat package deps, GH Actions CI.

## Use as a template

The recommended path is to launch a new app via `Sync-AppSecrets.ps1` on the
paperclip VPS (it creates the repo from this template, runs `bootstrap.ps1`
remotely, and wires GH Actions secrets in one shot). For the manual path:

```bash
gh repo create mi-j/<new-app> --template mi-j/ios-app-template --private
git clone git@github.com:mi-j/<new-app>.git
cd <new-app>
./bootstrap.ps1 -AppName MyApp -BundleId com.mi-j.myapp
```

`bootstrap.ps1` rewrites the placeholders below across every text file in the
repo, renames the `Sources/__APP_NAME__/` directory, then deletes itself.

## Placeholders

| Placeholder | Replace with | Example |
|-------------|--------------|---------|
| `__APP_NAME__` | Pascal-case app name (also Xcode scheme + target) | `ProDraftAI` |
| `__BUNDLE_ID__` | Reverse-DNS bundle identifier | `com.mi-j.prodraftai` |

## What's NOT in the template

- App-specific SwiftUI features (build per project)
- App icons / launch assets (drop into `Sources/__APP_NAME__/Resources/Assets.xcassets`)
- App Store metadata (`fastlane/metadata/`, `fastlane/screenshots/`) — generate per app
- `Pods/` / `*.xcodeproj/` — generated locally via `pod install` + `xcodegen generate`

## Required secrets / vars per app

The repo's `Settings → Secrets and variables → Actions` needs:

**Repo-level secrets** (`Sync-AppSecrets.ps1` populates these from
`C:\paperclip\shared\secrets.json`):

- `APPLE_TEAM_ID`, `APPLE_ID`
- `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_CONTENT`
- `MATCH_GIT_URL`, `MATCH_PASSWORD`
- `SUPABASE_URL_STAGING`, `SUPABASE_ANON_KEY_STAGING`,
  `SUPABASE_SERVICE_ROLE_KEY_STAGING`, `SUPABASE_PROJECT_REF_STAGING`
- (optional) `SLACK_WEBHOOK_URL`, `SENTRY_DSN`, `MIXPANEL_TOKEN`

## Layout

```
.github/workflows/ci.yml          # lint + test + UI test + archive + TestFlight
fastlane/Fastfile                 # lanes: lint, test, ui_test, beta, release, submit
fastlane/Appfile                  # bundle id / apple id / team id (env-driven)
fastlane/Matchfile                # cert sync (env-driven)
project.yml                       # XcodeGen project spec
Sources/__APP_NAME__/             # SwiftUI app shell
Podfile                           # Sentry + Mixpanel pods
Gemfile                           # Fastlane + CocoaPods
.gitignore
.env.example                      # full env spec; copy to .env locally
bootstrap.ps1                     # placeholder substitution (run once)
```

## License

MIT — see template owner.
