# Auth Service

This service owns the minimal user identity flow used by persistence restore flows.

It is intentionally not production authentication yet:

- no passwords
- no tokens
- no authorization checks

The current purpose is to provide stable user identities so the app can associate persisted sessions and locally cached
state with a selected user. The service boundary is intentionally named so it can later evolve into real authentication.

## Structure

- [`cmd/`](./cmd/)
  runtime wiring and server startup

- [`service/`](./service/)
  HTTP handlers, DTOs, route registration, and user identity storage boundaries

- [`k8s/`](./k8s/)
  Helm values for deploying this service

## HTTP Surface

Route registration lives in [`service/service.go`](./service/service.go).

Current routes:

- `GET /healthz`
  returns service health for local checks, container health checks, and Kubernetes probes

- `GET /users`
  lists existing users

- `POST /users`
  creates a new user from a display name

- `POST /users/select`
  returns an existing user identity without validating credentials

## Runtime Wiring

[`cmd/main.go`](./cmd/main.go) is the composition root.

The service uses PostgreSQL when `DATABASE_URL` is configured. Without `DATABASE_URL`, it falls back to in-memory storage
for lightweight local runs and tests.

## Environment Variables

- `PORT`
  HTTP port, defaults through [`services/shared/foundation/infra`](../shared/foundation/infra/)

- `APP_ENV`
  environment label used in logs

- `DATABASE_URL`
  PostgreSQL database URL for persistent user storage

## Kubernetes

Service-owned Kubernetes values live in [`k8s/`](./k8s/).
