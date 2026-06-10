# Interaction Record Module

This module owns the interaction record repository boundary.

Interaction records are write-side persistence for restore and analysis flows. The game service stores one record after a
successful interaction with:

- record id, session id, user id, and request id
- the original user input
- selected action and policy decision metadata
- the user-visible response text
- lightweight pipeline metadata such as response source
- creation timestamp

## Implementations

- [`in_memory_repository.go`](./in_memory_repository.go)
  stores records in process memory for lightweight local runs and focused tests

- [`persistence/postgres/`](./persistence/postgres/)
  stores records in PostgreSQL when `DATABASE_URL` is configured

The boundary stays service-owned so PostgreSQL can be replaced later without changing the handler or interaction
pipeline contracts.
