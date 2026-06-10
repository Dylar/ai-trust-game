# Session Module

This module owns the authoritative session repository boundary.

Its responsibility is intentionally small:

- store server-side session state
- load session state by session ID
- list sessions by user ID for restore flows
- keep the storage boundary explicit for the service layer and interaction flow

## Session Flow

The current flow is:

1. `POST /session/start` creates the initial session
2. the service stores it through [`Repository`](./repository.go)
3. `POST /interaction` reads `X-Session-Id` from request metadata
4. the service reads `X-User-Id` from request metadata
5. the service loads the authoritative session from the repository and verifies that the session belongs to the user
6. `GET /session/list` and `GET /session/{id}` expose user-scoped restore views
7. the interaction pipeline makes decisions against that authoritative state

The request identifies the user and the session.
The trusted session state comes from the repository.

## What Lives Here

- [`repository.go`](./repository.go)
  defines the storage boundary used by the service layer

- [`in_memory_repository.go`](./in_memory_repository.go)
  provides the in-memory implementation used for lightweight runs and focused tests

- [`persistence/postgres/`](./persistence/postgres/)
  provides the PostgreSQL implementation used when `DATABASE_URL` is configured

## Stored Object Shape

The repository stores [`domain.Session`](../../../shared/project/domain/session.go), which currently contains:

- `ID`
  the session identifier

- `UserID`
  the stable user identity that owns the session

- `Settings`
  the chosen game setup, such as role and mode

- `State`
  mutable authoritative state produced by system-controlled flow steps

- `CreatedAt` / `UpdatedAt`
  timestamps used by restore views and newest-first session lists

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

[`persistence/postgres.Repository`](./persistence/postgres/repository.go) stores sessions in the shared PostgreSQL
schema. It keeps the adapter under the game-service package so the service-owned repository boundary can be swapped
without leaking PostgreSQL details into handlers.

## Where It Is Used

The game service uses this boundary in:

- [`start_session_handler.go`](../start_session_handler.go)
  to save newly created sessions

- [`interaction_handler.go`](../interaction_handler.go)
  to load the authoritative session before processing and to persist session updates afterward

- [`session_query_handler.go`](../session_query_handler.go)
  to list and return user-scoped sessions for restore flows
