# PostgreSQL Persistence

This package contains generic PostgreSQL helpers for backend services.

It owns technical database mechanics:

- database connection configuration
- `database/sql` connection setup with the PostgreSQL driver
- connection health checks
- migration runner glue for `golang-migrate`

Service-specific repositories and SQL adapters must stay in the owning service packages. This package must not know
about project domain types such as users, sessions, interactions, audit events, or client logs.
