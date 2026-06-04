# Logging Service

This service owns log ingestion for the project backend.

It currently owns:

- local logging-service health checks
- client-side app log ingestion at `POST /logs/client`
- validation and normalization of incoming app log events into backend structured logs

The logging service does not own game rules, session state, audit semantics, public routing, or persistence.

## Structure

- [`cmd/`](./cmd/)
  runtime wiring and server startup

- [`service/`](./service/)
  HTTP handlers, route registration, and client log validation

- [`k8s/`](./k8s/)
  Helm values for deploying this service

## Runtime Wiring

[`cmd/main.go`](./cmd/main.go) is the composition root.

It creates:

- a logging-service logger
- the local health handler
- the client log ingestion handler
- the HTTP server and route registration

## HTTP Surface

Route registration lives in [`service/service.go`](./service/service.go).

Current routes:

- `GET /healthz`
  returns local logging-service health for container and Kubernetes probes

- `POST /logs/client`
  accepts client-side app log events routed through `gateway-service`

## Client Log Request

Client log payload:

```json
{
  "level": "INFO",
  "category": "interaction",
  "message": "message sent",
  "attributes": {}
}
```

Supported levels are `DEBUG`, `INFO`, `WARN`, and `ERROR`.

Validation errors:

- `invalid_client_log_level`
- `missing_client_log_message`
- `missing_client_log_category`

## Environment Variables

- `PORT`
  HTTP port, defaults through [`services/shared/foundation/infra`](../shared/foundation/infra/)

- `APP_ENV`
  environment label used in logs

## Kubernetes

Service-owned Kubernetes values live in [`k8s/`](./k8s/).

They define the `logging-service` values for `dev`, `test`, and `prod`.
