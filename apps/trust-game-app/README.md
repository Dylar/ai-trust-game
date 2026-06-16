# App

This module contains the Flutter client for the project.

This project contains the web-first Flutter client and Android platform scaffold for the AI Trust Game.

## Purpose

- provide a Flutter web app under `apps/trust-game-app/`
- keep Android platform scaffolding alongside the web target
- validate that the frontend can run independently
- let users start backend sessions, send interaction messages, and inspect analysis results

## Current State

The app currently has:

- a real `Home` screen as the app entrypoint
- a `SessionStart` screen reachable through navigator-based routing
- an `Interaction` screen that sends messages to the backend
- a `SessionDetail` screen that loads aggregated session analysis
- an `InteractionDetail` screen that loads request-level analysis
- app-wide dependency setup through `AppDependencies`
- app-wide configuration through `AppConfig`
- app-wide logging through `core/logging/` and `AppLogger`
- Dev, Test, and Prod flavor configuration
- app-wide selected-user state through `SelectedUserController`
- shared frontend models for `Session` and `Interaction`
- `services/` -> `data/` boundaries for session start, interaction creation, and analysis reads
- API clients using `http.Client` and `apiBaseUri`
- a Drift database under `data/drift/`
- Drift-backed repositories for cached sessions, interactions, and analysis views scoped to the selected user
- Drift-backed user persistence for users returned by the backend identity flow
- a loading screen that prepares user selection and refreshes cached sessions and interactions for loaded users
- a login/user-selection screen that selects an existing user or creates a new backend user

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

- `TrustGameApp` receives `AppDependencies` and passes them into `AppRouter`
- `AppConfig.fromEnvironment()` reads `APP_ENV` and `API_BASE_URL`
- `AppLogger` is the frontend logging boundary under `core/logging/`
- backend log shipping is implemented as a concrete adapter under `data/logging/`
- `AppDependencies.defaults()` creates repositories and API clients around shared app state without inventing a user ID
- `SelectedUserController` owns the currently selected user identity for user-scoped backend requests and local reads
- selected-user state is in-memory only; each app restart returns to user selection
- `main.dart` starts with the loading screen before the login screen
- startup sync loads all locally loaded users and updates their cached sessions and interactions before continuing
- navigator-based routing is centralized under `core/routing/`
- screens expose `routeName` and `open(...)`
- view models stay screen-local and are composed in the router before being passed into screens
- shared business vocabulary currently lives in `lib/models/`
- Home-specific list summaries are screen state objects, not shared domain models
- session flow currently follows `screen -> view model -> service -> repository/data`
- interaction flow currently follows `screen -> view model -> service -> repository/data`
- analysis detail flows currently follow `screen -> view model -> service -> repository/data`
- analysis detail screens read cached analysis first, then refresh from the backend and store fresh responses locally
- default app dependencies store cached sessions, interactions, and analysis views in Drift after a user is selected
- in-memory repository implementations remain available for focused tests and lightweight compositions
- current routing paths are `Home -> SessionStart -> Interaction`, `Home -> Interaction`, `Interaction -> SessionDetail`,
  and `Interaction -> InteractionDetail`

## Runtime Configuration

The app environment is read from `APP_ENV` via `--dart-define`.
Supported values are:

- `dev`
- `test`
- `prod`

The API base URL is read from `API_BASE_URL` via `--dart-define`.

For local web runs:

```bash
flutter run -d chrome --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://localhost:8080
```

For Android emulator runs against the local workstation backend, use the host bridge address instead of `localhost`:

```bash
flutter run --flavor dev -d android --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

For Android runs against the Raspberry Pi dev cluster, use the Tailscale MagicDNS origin:

```bash
flutter run --flavor dev -d android --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://raspberrypi.tail164eef.ts.net:30080
```

For test and prod Android builds, switch the native flavor and matching Dart define.
Android Gradle reserves flavor names starting with `test`, so the native Android test flavor is named `t3st` while the
Flutter app environment value remains `test`.

```bash
flutter run --flavor t3st -d android --dart-define=APP_ENV=test --dart-define=API_BASE_URL=http://10.0.2.2:8080
flutter run --flavor prod -d android --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://api.example.com
```

If `APP_ENV` is not provided, the app defaults to `dev`.
If `API_BASE_URL` is not provided, the app defaults to `http://localhost:8080`.

Current test structure:

- `test/testing/` for shared test bots such as `AppBot` and `BaseScreenBot`
- `test/testing/mocks/` for reusable transport and unit-test doubles
- `test/screens/<feature>/` for feature-local screen bots, processes, contexts, and screen tests

## Development Flow

For a manual local run:

1. Start the local compose stack from the repository root:

   ```bash
   make compose-up
   ```

2. Start the Flutter web client from `apps/trust-game-app/`:

   ```bash
   flutter run -d chrome --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://localhost:8080
   ```

3. Create a session, send one or more messages, then use the session and interaction analysis links from the
   interaction screen.

## Containerized Local Stack

The Docker Compose file under `infrastructure/docker/compose/` can build and run an optional local container stack:

- `gateway-service` on `http://localhost:8080`
- `game-service` as an internal backend service behind the gateway
- `logging-service` as an internal log ingestion service behind the gateway
- `audit-service` as an internal audit and analysis service behind the gateway
- RabbitMQ as the local async broker for audit events, with Management UI on `http://localhost:15672`
- Flutter web app on `http://localhost:3000`

Start it from the repository root:

```bash
make compose-up
```

Select another prepared model environment file when needed:

```bash
make compose-up COMPOSE_MODEL_ENV=groq
```

Stop it again:

```bash
make compose-down
```

Follow the combined stack logs:

```bash
make compose-logs
```

Restart the running containers without rebuilding:

```bash
make compose-restart
```

The compose setup keeps local ports and `API_BASE_URL` in the Compose file. The selected env file under
`infrastructure/docker/compose/env/` only configures the model provider used by the backend.

## Kubernetes

App-owned Kubernetes values live in [`k8s/`](./k8s/).

They deploy the `frontend-web` workload and the current `app-entry` Nginx entrypoint.

For app-specific deployment values, image repositories, and entrypoint ports, see [`k8s/README.md`](./k8s/README.md).
For the general Kubernetes layout, see [`docs/deployment/k8s.md`](../../docs/deployment/k8s.md).
