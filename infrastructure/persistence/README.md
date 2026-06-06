# Persistence Infrastructure

This area contains persistence infrastructure assets that are project-specific but not owned by one service.

Current assets:

- [`postgres/`](./postgres/)
  PostgreSQL migrations for the backend persistence schema

Runtime wiring, credentials, volumes, and deployment-specific configuration belong in the Docker Compose and Kubernetes
areas.
