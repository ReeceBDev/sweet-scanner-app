# sweet-scanner-app

Flutter app (web-first) for scanning sweets, built on the vps-1-infra-repo
`template/` deploy chain.

## Layout

- `lib/` — the Flutter app (all platforms generated: android, ios, linux, macos, web, windows)
- `.woodpecker/pipeline.yaml` — CI: `flutter pub get` + `analyze` + `test`, then docker build + push
- `Dockerfile` — multi-stage: `flutter build web` → hardened `nginx-unprivileged` on :8080
- `nginx.conf` — static hardening law (CSP, SPA fallback to index.html, GET/HEAD only, healthz)
- `deploy/compose.yaml` — runtime; TAG + PORT injected by the deployer
- `deploy/ports.env` — this repo's static port triple

## Ports (static, owned by this repo)

| env  | port |
|------|------|
| dev         | 5088 |
| pre-release | 5089 |
| prod        | 5090 |

## Flow

push to `dev` → `dev-<sha8>` image → dev env (5088) · push to `master` →
`master-<sha8>` image → pre-release env (5089) · prod (5090) moves only by
rbowen's promotion. Services are addressed by port at divinearts.co.uk.

## Develop

```sh
flutter pub get
flutter run -d chrome   # or any device
flutter test
```
