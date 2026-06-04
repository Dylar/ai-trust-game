# Session Module

This module owns the authoritative session repository boundary.

Its responsibility is intentionally small:

- store server-side session state
- load session state by session ID
- keep the storage boundary explicit for the service layer and interaction flow

## Session Flow

The current flow is:

1. `POST /session/start` creates the initial session
2. the service stores it through [`Repository`](./repository.go)
3. `POST /interaction` reads `X-Session-Id` from request metadata
4. the service loads the authoritative session from the repository
5. the interaction pipeline makes decisions against that authoritative state

The request identifies the session.
The trusted session state comes from the repository.

## What Lives Here

- [`repository.go`](./repository.go)
  defines the storage boundary used by the service layer

- [`in_memory_repository.go`](./in_memory_repository.go)
  provides the current in-memory implementation

## Stored Object Shape

The repository stores [`domain.Session`](../../../shared/project/domain/session.go), which currently contains:

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
  is the server-side role state the system trusts during policy decisions

- `State.SecretUnlocked`
  is authoritative state that can enable secret access in stricter modes

## Implementation

[`InMemoryRepository`](./in_memory_repository.go) stores sessions in process memory.
Stored sessions reset when the service restarts.

## Where It Is Used

The game service uses this boundary in:

- [`start_session_handler.go`](../start_session_handler.go)
  to save newly created sessions

- [`interaction_handler.go`](../interaction_handler.go)
  to load the authoritative session before processing and to persist session updates afterward
