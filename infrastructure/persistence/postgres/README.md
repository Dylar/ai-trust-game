# PostgreSQL Infrastructure

This area contains project PostgreSQL schema migrations.

Migrations use `golang-migrate` with explicit numbered up/down SQL files:

- [`migrations/`](./migrations/)
  backend persistence schema migrations

Run migrations from the repository root:

```sh
make migrate-up POSTGRES_DATABASE_URL='postgres://user:password@localhost:5432/ai_trust_game?sslmode=disable'
make migrate-down POSTGRES_DATABASE_URL='postgres://user:password@localhost:5432/ai_trust_game?sslmode=disable'
```

The shared PostgreSQL helper package lives under
[`services/shared/foundation/persistence/postgres`](../../../services/shared/foundation/persistence/postgres/).
