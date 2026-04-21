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

The app currently renders one simple bootstrap screen that confirms the Flutter app is running.

Prepared targets:

- Web
- Android

Current `lib/` structure:

- `lib/core/app/`
- `lib/core/theme/`
- `lib/l10n/`
- `lib/models/`
- `lib/screens/home/`
- `lib/screens/session_start/`

Current test structure:

- `test/testing/` for shared test bots such as `AppBot` and `BaseScreenBot`
- `test/screens/<feature>/` for feature-local screen bots, processes, contexts, and screen tests

Later phases of the frontend work should follow the structure described in
[`docs/architecture-frontend.md`](../docs/architecture-frontend.md).

## Next Steps

The next frontend increments should focus on:

- wiring the session start flow to the backend
- adding interaction flow against the existing backend endpoints
