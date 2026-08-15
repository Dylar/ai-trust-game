# Logging Service

This service owns log ingestion for the project backend.

It currently owns:

- local logging-service health checks
- client-side app log ingestion at `POST /logs/client`
- validation and persistent RabbitMQ publishing of incoming app log events
- RabbitMQ consumption and normalization of queued app log events into backend structured logs

The logging service does not own game rules, session state, audit semantics, public routing, or log persistence.
Backend services do not call this API; they write structured logs to stdout for later platform-level collection.

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
- the client log ingestion handler and RabbitMQ publisher
- the RabbitMQ client-log consumer and structured-log worker
- the HTTP server and route registration

The HTTP handler validates a client log and returns `202 Accepted` only after RabbitMQ accepts the persistent message.
The worker consumes the queue in the same service process. Invalid messages are dead-lettered; transient processing
failures use the configured delayed retry route.

## HTTP Surface

Route registration lives in [`service/service.go`](./service/service.go).

Current routes:

- `GET /healthz`
  returns local logging-service health for container and Kubernetes probes

- `POST /logs/client`
  validates and queues client-side app log events routed through `gateway-service`

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

- `PORT`, `APP_ENV`
  standard service runtime configuration
- `RABBITMQ_URL`
  RabbitMQ endpoint used for client-log publishing and consumption
- `CLIENT_LOGS_EXCHANGE`, `CLIENT_LOGS_QUEUE`, `CLIENT_LOGS_ROUTING_KEY`
  main client-log route
- `CLIENT_LOGS_RETRY_EXCHANGE`, `CLIENT_LOGS_RETRY_QUEUE`, `CLIENT_LOGS_RETRY_DELAY_MILLIS`
  delayed retry route and delay
- `CLIENT_LOGS_DEAD_LETTER_EXCHANGE`, `CLIENT_LOGS_DEAD_LETTER_QUEUE`
  rejected-message route

## Kubernetes

Service-owned Kubernetes values live in [`k8s/`](./k8s/).

They define the `logging-service` values for `dev`, `test`, and `prod`.
