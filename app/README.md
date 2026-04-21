# App

This module contains the Flutter client for the project.

This project starts with a minimal web-first bootstrap and already includes the Android platform scaffold so the
repository has a shared Flutter client entrypoint before session flow and interaction features are added.

## Purpose

- provide a Flutter web app under `app/`
- prepare Android alongside web so most future work can stay in `lib/`
- validate that the frontend can run independently
- create the base for later session start and interaction screens

## Current State

The app currently has:

- a real `Home` screen as the app entrypoint
- a `SessionStart` screen reachable through navigator-based routing
- an `Interaction` screen with a local placeholder message/answer loop
- app-wide dependency access through `AppDependencies`
- app-wide configuration through `AppConfig`
- shared frontend models for `Session` and `Interaction`
- `services/` -> `data/` boundaries for session start and local interaction creation
- API clients prepared with `http.Client` and `apiBaseUri`
- an in-memory `SessionRepository` that keeps recent sessions for the current app runtime
- an in-memory `InteractionRepository` that stores local placeholder interactions

Prepared targets:

- Web
- Android

Current `lib/` structure:

- `lib/core/app/`
- `lib/core/config/`
- `lib/data/`
- `lib/core/theme/`
- `lib/l10n/`
- `lib/models/`
- `lib/services/`
- `lib/screens/home/`
- `lib/screens/interaction/`
- `lib/screens/session_start/`

Current frontend architecture choices:

- `TrustGameApp` wraps the app with `AppDependencies`
- `AppConfig.fromEnvironment()` reads `API_BASE_URL`
- navigator-based routing is centralized under `core/routing/`
- screens expose `routeName` and `open(...)`
- view models stay screen-local and receive dependencies from the screen
- shared business vocabulary currently lives in `lib/models/`
- Home-specific list summaries are screen state objects, not shared domain models
- session flow currently follows `screen -> service -> repository/data`
- interaction flow currently follows `screen -> service -> repository/data` and creates local placeholder answers before backend wiring
- recent sessions are intentionally in-memory only for now and reset when the app restarts
- current routing paths are `Home -> SessionStart -> Interaction` and `Home -> Interaction`

## Runtime Configuration

The API base URL is read from `API_BASE_URL` via `--dart-define`.

For local web runs:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

For Android emulator runs, use the host bridge address instead of `localhost`:

```bash
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

If `API_BASE_URL` is not provided, the app defaults to `http://localhost:8080`.

Current test structure:

- `test/testing/` for shared test bots such as `AppBot` and `BaseScreenBot`
- `test/screens/<feature>/` for feature-local screen bots, processes, contexts, and screen tests

Later phases of the frontend work should follow the structure described in
[`docs/architecture-frontend.md`](../docs/architecture-frontend.md).

## Next Steps

The next frontend increments should focus on:

- replacing the placeholder session API client with the real backend call for session start
- adding interaction flow against the existing backend endpoints
