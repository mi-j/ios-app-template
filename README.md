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

## What's included (buildable & shippable out of the box)

- Compiling SwiftUI shell + **baseline unit and UI tests** so CI is green from commit one.
- A **placeholder app icon** (single-size 1024, in `Assets.xcassets`) so the first
  TestFlight upload passes Apple's bundle checks. **Replace it with the real icon
  before any public release.**
- Generated-Info.plist keys for launch screen + orientations, manual `match` signing
  pinned to the App Store profile, and a one-time signing-bootstrap workflow.

## What's NOT in the template

- App-specific SwiftUI features (build per project)
- The **real** app icon / launch assets (replace the placeholder in `Sources/__APP_NAME__/Resources/Assets.xcassets`)
- App Store metadata (`fastlane/metadata/`, `fastlane/screenshots/`) — generate per app
- `Pods/` / `*.xcodeproj/` — generated locally via `pod install` + `xcodegen generate`

## Shipping a new app

1. Register the App ID `__BUNDLE_ID__` in the Apple Developer portal and create the
   app record in App Store Connect.
2. Run the **Match — Bootstrap Signing** workflow once (Actions tab → `match-setup.yml`)
   to mint the App Store provisioning profile into `mi-j/ios-certificates`.
3. Ship: run **Release** (`release.yml`) with `lane=beta` for TestFlight, or push a `v*` tag.

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
.github/workflows/ci.yml          # push/PR: lint + unit + UI tests (macos-15, xcodegen)
.github/workflows/release.yml     # dispatch + v* tags: beta/release/submit (macos-26)
.github/workflows/match-setup.yml # one-time: mint the App Store signing profile
fastlane/Fastfile                 # lanes: lint, test, ui_test, sync_signing, bootstrap_signing, beta, release, submit
fastlane/Appfile                  # bundle id / apple id / team id (env-driven)
fastlane/Matchfile                # cert sync (env-driven)
project.yml                       # XcodeGen project spec (GENERATE_INFOPLIST_FILE, signing, icon)
Sources/__APP_NAME__/             # SwiftUI app shell
Sources/__APP_NAME__/Resources/Assets.xcassets/  # placeholder AppIcon (replace before release)
Tests/__APP_NAME__Tests/          # baseline unit test
Tests/__APP_NAME__UITests/        # baseline UI test
Podfile                           # Sentry + Mixpanel pods
Gemfile                           # Fastlane + CocoaPods
.gitignore
.env.example                      # full env spec; copy to .env locally
bootstrap.ps1                     # placeholder substitution + renames (run once)
```

## License

MIT — see template owner.
