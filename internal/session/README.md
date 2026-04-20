# Session Module

This module owns the authoritative session repository boundary.

Its responsibility is intentionally small:

- store server-side session state
- load session state by session ID
- keep the storage boundary explicit for the service layer and interaction flow

## Why This Boundary Matters

The project is about showing what the system should trust.

For that reason, the current session must be loaded from trusted server-side state instead of being reconstructed from
user input on each request.

The current flow is:

1. `POST /session/start` creates the initial session
2. the service stores it through [`Repository`](./repository.go)
3. later `POST /interaction` reads `X-Session-Id` from request metadata
4. the service loads the authoritative session from the repository
5. the interaction pipeline makes decisions against that authoritative state

The important point is:

> the request may identify a session, but it does not define the trusted session state

## What Lives Here

- [`repository.go`](./repository.go)
  defines the storage boundary used by the service layer

- [`in_memory_repository.go`](./in_memory_repository.go)
  provides the current in-memory implementation

## Stored Object Shape

The repository stores [`domain.Session`](../domain/session.go), which currently contains:

- `ID`
  the session identifier

- `Settings`
  the chosen game setup, such as role and mode

- `State`
  mutable authoritative state produced by system-controlled flow steps

This split is important:

- `Settings.Role`
  is the role chosen at session start

- `State.TrustedRole`
  is the server-side role state the system currently trusts during later decisions

- `State.SecretUnlocked`
  is authoritative state that can enable secret access in stricter modes

## Current Implementation

[`InMemoryRepository`](./in_memory_repository.go) is the first implementation on purpose.

At the current project stage, it keeps the feedback loop small while preserving a clean replacement point for later
persistent storage.

That means:

- the service and interaction flow already depend on a repository boundary
- persistence can change later without rewriting handler or processor logic

## Where It Is Used

The main service uses this boundary in:

- [`start_session_handler.go`](../../services/main-service/service/start_session_handler.go)
  to save newly created sessions

- [`interaction_handler.go`](../../services/main-service/service/interaction_handler.go)
  to load the authoritative session before processing and to persist session updates afterward
