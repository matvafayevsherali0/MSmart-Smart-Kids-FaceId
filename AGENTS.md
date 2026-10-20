# AGENTS.md

## Project overview

`msmart_kids_faceid` is a private Flutter mobile application for MSmart Kids FaceId. It targets Android and iOS and integrates with the MSmart backend and Hikvision access-control devices.

- Flutter channel/version observed locally: stable, Flutter 3.44.5, Dart 3.12.2.
- Dart SDK constraint: `^3.11.4` in `pubspec.yaml`.
- State management: `bloc`/`flutter_bloc` with `Equatable` states.
- Navigation: `go_router` in `lib/app/navigation/router.dart`.
- Dependency injection: `get_it` in `lib/core/utils/service_locator.dart`.
- Serialization: `json_serializable`; generated `*.g.dart` files are committed.
- There is currently no `test/`, `integration_test/`, or `.github/` test workflow in the repository.

## Repository layout

- `lib/main.dart`: app bootstrap; initializes local storage and the service locator.
- `lib/app.dart`: root widget, global BLoC providers, theme, screen sizing, and unauthorized-session redirect.
- `lib/app/navigation/`: application routes and route payloads.
- `lib/core/`: shared network, storage, vault/update, error, utility, and service-locator code.
- `lib/features/<feature>/`: feature-first code. Where present, keep `data/`, `domain/`, and `presentation/` responsibilities separate.
- `lib/assets/`: colors, themes, icons, fonts, and language JSON files.
- `android/` and `ios/`: native platform configuration, permissions, signing, and CocoaPods/Xcode settings.
- The current iOS minimum deployment target is `15.0`; keep `ios/Podfile` and all Runner build configurations aligned when changing it.

Important feature areas include authentication, organizations, users, devices, category selection, face enrollment, Hikvision integration, account management, and user comparison.

## Development workflow

Run commands from the repository root:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format lib
flutter analyze
flutter test
```

Before claiming a change is complete, run the checks relevant to the changed files. If model annotations or JSON fields changed, run `build_runner` and verify that generated files are updated. Do not edit `*.g.dart` files by hand.

For platform smoke checks, use the platform-specific Flutter build/run command needed for the change. Release builds require local Android signing configuration and should not be attempted with guessed credentials.

## Coding conventions

- Follow the existing Dart formatting and naming style; run `dart format` on changed Dart files.
- Keep business logic out of widgets. Dispatch events from widgets, handle async work in BLoCs, and keep remote/local I/O in data sources or services.
- Prefer the existing flow: data source -> repository/mapper -> domain model or `Either<Failure, T>` -> BLoC -> presentation.
- Register new shared dependencies in `lib/core/utils/service_locator.dart` and inject them through constructors where practical.
- Use `DioSettings` for MSmart backend requests so authorization, token refresh, language headers, and 401 handling remain centralized.
- Use `HikvisionService` for Hikvision device calls; preserve its digest-authentication and URL normalization behavior.
- Add backend paths to `lib/assets/constants/network_constants.dart` instead of scattering endpoint strings across features.
- Add routes to `router.dart` and keep route payloads explicit and null-safe.
- Put user-facing text in all supported language files (`en.json`, `ru.json`, `uz-Latn.json`, and `uz-Cyrl.json`) and expose keys through `LocaleKeys` where that pattern is used.
- Reuse shared widgets, colors, themes, icons, and fonts before creating duplicate UI primitives.
- Preserve public API response field names and nullable/default parsing behavior unless the backend contract is intentionally changed.

## Security and data handling

- Never print, paste, or commit access tokens, refresh tokens, passwords, Hikvision credentials, vault tokens, signing passwords, or private keys.
- Treat `android/key.properties`, `upload-keystore.jks`, endpoint configuration, and the vault-related constants as sensitive. Do not expose their contents in logs, screenshots, tests, or review comments.
- Do not make live backend or Hikvision calls from unit tests. Mock the data source/service and use deterministic fixtures.
- Avoid logging request/response bodies in production; `Dio` logging is currently enabled for development and must be reviewed before release builds.
- Preserve TLS and certificate validation behavior. Do not broaden the debug certificate exception or enable cleartext traffic for new hosts without an explicit security review.
- Be careful with personally identifiable information and face-enrollment images. Do not add them to fixtures or commits unless they are synthetic and approved.

## Change discipline

- Inspect `git status` before editing and preserve unrelated user changes.
- Keep changes focused; do not reformat or regenerate unrelated files.
- Update platform configuration only when required by the feature, and check both Android and iOS behavior for permission/authentication changes.
- When changing authentication, storage keys, routes, API contracts, or generated models, check all callers and the logout/401-refresh flow.
- If a change affects release metadata, verify both `pubspec.yaml` and `android/app/build.gradle.kts`; this project currently keeps Android and Flutter/iOS version values separately.
- Document any new setup step, required local secret, or device prerequisite in `README.md` rather than embedding credentials in source.
