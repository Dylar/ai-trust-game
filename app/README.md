# App

This module contains the Flutter client for the project.

This project contains the web-first Flutter client and Android platform scaffold for the AI Trust Game.

## Purpose

- provide a Flutter web app under `app/`
- prepare Android alongside web so most future work can stay in `lib/`
- validate that the frontend can run independently
- let users start backend sessions, send interaction messages, and inspect analysis results

## Current State

The app currently has:

- a real `Home` screen as the app entrypoint
- a `SessionStart` screen reachable through navigator-based routing
- an `Interaction` screen that sends messages to the backend
- a `SessionDetail` screen that loads aggregated session analysis
- an `InteractionDetail` screen that loads request-level analysis
- app-wide dependency access through `AppDependencies`
- app-wide configuration through `AppConfig`
- app-wide logging through `core/logging/` and `AppLogger`
- Dev, Test, and Prod flavor configuration
- one runtime-scoped generated user ID sent as `X-User-Id`
- shared frontend models for `Session` and `Interaction`
- `services/` -> `data/` boundaries for session start, interaction creation, and analysis reads
- API clients using `http.Client` and `apiBaseUri`
- an in-memory `SessionRepository` that keeps recent sessions for the current app runtime
- an in-memory `InteractionRepository` that stores backend interaction results for the current app runtime

Prepared targets:

- Web
- Android

Current `lib/` structure:

- `lib/core/app/`
- `lib/core/config/`
- `lib/core/logging/`
- `lib/core/routing/`
- `lib/core/user/`
- `lib/data/`
- `lib/data/logging/`
- `lib/core/theme/`
- `lib/l10n/`
- `lib/models/`
- `lib/services/`
- `lib/screens/home/`
- `lib/screens/interaction/`
- `lib/screens/interaction_detail/`
- `lib/screens/session_detail/`
- `lib/screens/session_start/`

Current frontend architecture choices:

- `TrustGameApp` wraps the app with `AppDependencies`
- `AppConfig.fromEnvironment()` reads `APP_FLAVOR` and `API_BASE_URL`
- `AppLogger` is the frontend logging boundary under `core/logging/`
- backend log shipping is implemented as a concrete adapter under `data/logging/`
- `UserIdentity.newRuntimeIdentity()` creates an in-memory user ID for the current app runtime
- navigator-based routing is centralized under `core/routing/`
- screens expose `routeName` and `open(...)`
- view models stay screen-local and are composed in the router before being passed into screens
- shared business vocabulary currently lives in `lib/models/`
- Home-specific list summaries are screen state objects, not shared domain models
- session flow currently follows `screen -> service -> repository/data`
- interaction flow currently follows `screen -> service -> repository/data`
- analysis detail flows currently follow `screen -> service -> data`
- recent sessions are intentionally in-memory only for now and reset when the app restarts
- interactions are intentionally in-memory only for now and reset when the app restarts
- current routing paths are `Home -> SessionStart -> Interaction`, `Home -> Interaction`, `Interaction -> SessionDetail`,
  and `Interaction -> InteractionDetail`

## Runtime Configuration

The app flavor is read from `APP_FLAVOR` via `--dart-define`.
Supported values are:

- `dev`
- `test`
- `prod`

The API base URL is read from `API_BASE_URL` via `--dart-define`.

For local web runs:

```bash
flutter run -d chrome --dart-define=APP_FLAVOR=dev --dart-define=API_BASE_URL=http://localhost:8080
```

For Android emulator runs, use the host bridge address instead of `localhost`:

```bash
flutter run --flavor dev -d android --dart-define=APP_FLAVOR=dev --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

For test and prod Android builds, switch the native flavor and matching Dart define.
Android Gradle reserves flavor names starting with `test`, so the native Android test flavor is named `t3st` while the
Flutter app flavor remains `test`.

```bash
flutter run --flavor t3st -d android --dart-define=APP_FLAVOR=test --dart-define=API_BASE_URL=http://10.0.2.2:8080
flutter run --flavor prod -d android --dart-define=APP_FLAVOR=prod --dart-define=API_BASE_URL=https://api.example.com
```

If `APP_FLAVOR` is not provided, the app defaults to `dev`.
If `API_BASE_URL` is not provided, the app defaults to `http://localhost:8080`.

Current test structure:

- `test/testing/` for shared test bots such as `AppBot` and `BaseScreenBot`
- `test/testing/mocks/` for reusable transport and unit-test doubles
- `test/screens/<feature>/` for feature-local screen bots, processes, contexts, and screen tests

Later phases of the frontend work should follow the structure described in
[`docs/architecture-frontend.md`](../docs/architecture-frontend.md).

## Development Flow

For a manual local run:

1. Start the backend from the repository root:

   ```bash
   make run SERVICE=main-service
   ```

2. Start the Flutter web client from `app/`:

   ```bash
   flutter run -d chrome --dart-define=APP_FLAVOR=dev --dart-define=API_BASE_URL=http://localhost:8080
   ```

3. Create a session, send one or more messages, then use the session and interaction analysis links from the
   interaction screen.

## Containerized Local Stack

The repository root `compose.yml` can build and run the current local stack:

- `main-service` on `http://localhost:8080`
- Flutter web app on `http://localhost:3000`

Start it from the repository root:

```bash
make compose-up
```

Stop it again:

```bash
make compose-down
```

The compose setup currently builds the web app with `APP_FLAVOR=dev` and `API_BASE_URL=http://localhost:8080`.
