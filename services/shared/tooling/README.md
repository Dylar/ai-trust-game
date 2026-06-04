# Shared Service Tooling

This directory contains shared backend service development helpers.

Current packages:

- [`scripts/`](./scripts/)
  helpers for manual service scripts

- [`tests/`](./tests/)
  HTTP test helpers, assertions, and reusable test doubles

Tooling packages must not own product behavior.
They should support tests and local scripts without becoming an alternate implementation path.
