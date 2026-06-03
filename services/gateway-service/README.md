# Gateway Service

This service is the public backend entry point for external access into the cluster.

It currently owns:

- local gateway health checks
- public HTTP routing for backend API paths
- reverse proxying to the internal `game-service`
- reverse proxying app log ingestion to the internal `logging-service`
- reverse proxying analysis reads to the internal `audit-service`
- request metadata forwarding for request, session, and user identifiers

The gateway does not own game rules, session state, audit analysis, log storage, or persistence.

## Structure

- [`cmd/`](./cmd/)
  runtime wiring and server startup

- [`service/`](./service/)
  HTTP handlers, route registration, and proxy behavior

- [`k8s/`](./k8s/)
  Helm values for deploying this service

## Runtime Wiring

[`cmd/main.go`](./cmd/main.go) is the composition root.

It creates:

- a gateway logger
- the local health handler
- reverse proxy handlers for `game-service` and `logging-service`
- the HTTP server and route registration

## HTTP Surface

Route registration lives in [`service/service.go`](./service/service.go).

Current routes:

- `GET /healthz`
  returns local gateway health for container and Kubernetes probes

- `/analysis/*`
  proxies analysis requests to `audit-service`

- `/chat`
  proxies chat requests to `game-service`

- `/interaction`
  proxies interaction requests to `game-service`

- `/logs/*`
  proxies log requests to `logging-service`

- `/session/*`
  proxies session requests to `game-service`

## Request Metadata

The gateway uses [`services/shared/foundation/network`](../shared/foundation/network/) middleware to create a request ID
and read incoming session and user metadata.

Forwarded headers:

- `X-Request-Id`
- `X-Session-Id`
- `X-User-Id`
- `X-Forwarded-Proto`

Header meaning:

- `X-Request-Id`
  one identifier for the current request so gateway and backend logs can be correlated
- `X-Session-Id`
  the current trust-game session identifier when the app already has one
- `X-User-Id`
  the app runtime user identifier used to connect client actions to one anonymous runtime identity
- `X-Forwarded-Proto`
  the original client-facing protocol, usually `http` or `https`; reverse proxies use it so backend services can know
  whether the outside request arrived over HTTP or HTTPS even when internal service-to-service traffic is plain HTTP

## Environment Variables

- `PORT`
  HTTP port, defaults through [`services/shared/foundation/infra`](../shared/foundation/infra/)

- `APP_ENV`
  environment label used in logs

- `GAME_SERVICE_URL`
  internal URL for the game service, defaults to `http://game-service:8080`

- `LOGGING_SERVICE_URL`
  internal URL for the logging service, defaults to `http://logging-service:8080`

- `AUDIT_SERVICE_URL`
  internal URL for the audit service, defaults to `http://audit-service:8080`

## Kubernetes

Service-owned Kubernetes values live in [`k8s/`](./k8s/).

They define the `gateway-service` values for `dev`, `test`, and `prod`.
