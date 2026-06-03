# Audit Service

This service owns audit event ingestion, audit analysis, and audit read models.

It currently owns:

- local audit-service health checks
- RabbitMQ audit event consumption
- `POST /audit/events` as an internal HTTP fallback/debug ingestion endpoint
- request-level analysis reads at `GET /analysis/request/{requestId}`
- session-level analysis reads at `GET /analysis/session/{sessionId}`
- in-memory request analysis storage until persistence is introduced later

The audit service does not own game state transitions, public routing, generic app logging, or persistence setup.

## Structure

- [`cmd/`](./cmd/)
  runtime wiring and server startup

- [`service/`](./service/)
  HTTP handlers and route registration

- [`service/audit/`](./service/audit/)
  audit analysis, repositories, sinks, and intent summarization

- [`k8s/`](./k8s/)
  Helm values for deploying this service

## HTTP Surface

Current routes:

- `GET /healthz`
  returns local audit-service health for container and Kubernetes probes

- `POST /audit/events`
  accepts audit events from internal services as a fallback/debug path

- `GET /analysis/request/{requestId}`
  returns one stored request analysis

- `GET /analysis/session/{sessionId}`
  returns the aggregated session analysis plus ordered request analyses

## Runtime Behavior

`game-service` publishes audit events to RabbitMQ.
`audit-service` consumes the audit event queue and processes events through the same analyzing sink used by the HTTP
fallback endpoint.
The audit service keeps request events in memory until the request is complete, then creates a request analysis.

Persistence is intentionally out of scope until Phase 13.
